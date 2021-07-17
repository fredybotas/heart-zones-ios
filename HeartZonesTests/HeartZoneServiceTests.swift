//
//  HeartZoneServiceTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 09/07/2021.
//

import XCTest
import Combine

@testable import HeartZones_WatchKit_Extension

class HeartZoneServiceTests: XCTestCase {
    var workoutServiceFake: WorkoutServiceFake!
    var deviceBeeperMock: DeviceBeeperMock!
    var sut: HeartZoneService!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        self.workoutServiceFake = WorkoutServiceFake()
        self.deviceBeeperMock = DeviceBeeperMock()
        self.sut = HeartZoneService(workoutService: workoutServiceFake, deviceBeeper: deviceBeeperMock)
        self.cancellables.removeAll()
    }
    
    func getBpmSampleFromHeartZone(zone: HeartZone) -> Int {
        return zone.bpmRange.lowerBound + 1
    }
    
    func testInitialization() {
        self.workoutServiceFake.changeState(state: .notPresent)
        self.workoutServiceFake.sendBpmChange(bpm: 10)

        self.sut.getHeartZonePublisher().sink { zone in
            XCTAssert(false, "Zone should not be changed")
        }.store(in: &cancellables)
    }
    
    func testInitializationRunning() {
        self.workoutServiceFake.changeState(state: .running)
        var zoneChangeCalled = false
        self.sut.getHeartZonePublisher().sink { zone in
            zoneChangeCalled = true
        }
        .store(in: &cancellables)

        self.workoutServiceFake.sendBpmChange(bpm: 10)

        XCTAssertTrue(zoneChangeCalled, "We should receive new zone")
    }
    
    func testZoneShouldChangeOnlyOnceWhenBpmInSameZone() {
        self.workoutServiceFake.changeState(state: .running)
        var zoneChangeCalledCount = 0
        self.sut.getHeartZonePublisher().sink { zone in
            zoneChangeCalledCount += 1
        }
        .store(in: &cancellables)
        
        self.workoutServiceFake.sendBpmChange(bpm: 10)
        self.workoutServiceFake.sendBpmChange(bpm: 20)
        
        XCTAssertEqual(zoneChangeCalledCount, 1)
    }
    
    func testZoneTransmission() {
        self.workoutServiceFake.changeState(state: .running)

        var firstZone: HeartZone?
        var lastZone: HeartZone?
        self.sut.getHeartZonePublisher().sink { zone in
            if firstZone == nil {
                firstZone = zone
            } else if lastZone == nil {
                lastZone = zone
            }
        }
        .store(in: &cancellables)
        
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[0]))
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[1]))

        guard let firstZone = firstZone, let lastZone = lastZone else {
            XCTAssert(false, "Both zones should be received")
            return
        }
        
        XCTAssertNotEqual(firstZone, lastZone)
    }
    
    func testBeepingUp() {
        self.workoutServiceFake.changeState(state: .running)
        
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[0]))
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[1]))

        XCTAssertEqual(deviceBeeperMock.changeZoneAlertCalledCount, 1)
        XCTAssertEqual(deviceBeeperMock.changeZoneAlertCallSequence[0], .up)
    }
    
    func testBeepingDown() {
        self.workoutServiceFake.changeState(state: .running)
        
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[1]))
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[0]))

        XCTAssertEqual(deviceBeeperMock.changeZoneAlertCalledCount, 1)
        XCTAssertEqual(deviceBeeperMock.changeZoneAlertCallSequence[0], .down)
    }
    
    func testEnteringActiveZone() {
        self.workoutServiceFake.changeState(state: .running)
        
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[3]))

        XCTAssertEqual(deviceBeeperMock.stopAlertingCalledCount, 1)
    }
    
    func testLeavingActiveZoneDown() {
        self.workoutServiceFake.changeState(state: .running)
        
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[3]))
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[2]))
        
        XCTAssertEqual(deviceBeeperMock.startLowRateAlertCalledCount, 1)
    }
    
    
    func testLeavingActiveZoneUp() {
        self.workoutServiceFake.changeState(state: .running)
        
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[3]))
        self.workoutServiceFake.sendBpmChange(bpm: getBpmSampleFromHeartZone(zone: self.sut.activeHeartZoneSetting.zones[4]))
        
        XCTAssertEqual(deviceBeeperMock.startHighRateAlertCalledCount, 1)
    }
    
    func testContinousResubscriptionForZones() {
        self.workoutServiceFake.changeState(state: .running)
        var firstTimeCalled = false
        var completed = false
        self.sut
            .getHeartZonePublisher()
            .sink(receiveCompletion: { completion in
            completed = true
        }, receiveValue: { val in
            firstTimeCalled = true
        }).store(in: &cancellables)

        self.workoutServiceFake.sendBpmChange(bpm: 10)
        XCTAssert(firstTimeCalled)
        self.workoutServiceFake.resetSubscribers()
        self.workoutServiceFake.changeState(state: .finished)
        XCTAssert(completed)

        self.workoutServiceFake.changeState(state: .notPresent)
        self.workoutServiceFake.changeState(state: .running)
        
        var secondTimeCalled = false
        self.sut.getHeartZonePublisher().sink { val in
            secondTimeCalled = true
        }.store(in: &cancellables)
        self.workoutServiceFake.sendBpmChange(bpm: 10)

        XCTAssert(secondTimeCalled)
    }
    
    
}
