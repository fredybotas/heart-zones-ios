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
    var beepingServiceMock: BeepingServiceMock!
    var healthKitServiceMock: HealthKitServiceMock!
    var settingsServiceFake: SettingsServiceFake!
    
    var sut: HeartZoneService!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        self.workoutServiceFake = WorkoutServiceFake()
        self.beepingServiceMock = BeepingServiceMock()
        self.healthKitServiceMock = HealthKitServiceMock()
        self.settingsServiceFake = SettingsServiceFake()
        
        self.sut = HeartZoneService(workoutService: workoutServiceFake, beepingService: beepingServiceMock, healthKitService: healthKitServiceMock, settingsService: self.settingsServiceFake)
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
    
    func testSetActiveHeartZoneSetting() {
        self.workoutServiceFake.changeState(state: .running)
        
        XCTAssertNotNil(self.sut.activeHeartZoneSetting)
    }
    
    func testZoneChange() {
        self.workoutServiceFake.changeState(state: .running)

        var firstZone: HeartZone?
        self.sut.getHeartZonePublisher().sink { zone in
            firstZone = zone
        }
        .store(in: &cancellables)
        
        guard let sampleZone1 = self.sut.activeHeartZoneSetting?.zones[0] else { XCTAssert(false, "Zone should be available"); return }
        
        self.sut.setState(state: HeartZoneActiveState(zone: sampleZone1, stateManager: self.sut, movement: .up, settingsService: self.settingsServiceFake))
        
        guard let firstZone = firstZone else {
            XCTAssert(false, "zone should be received")
            return
        }
        
        XCTAssertEqual(firstZone, sampleZone1)
    }
    
    
    func testZoneShouldChangeOnlyOnceWhenBpmInSameZone() {
        self.workoutServiceFake.changeState(state: .running)
        var zoneChangeCalledCount = 0
        self.sut.getHeartZonePublisher().sink { zone in
            zoneChangeCalledCount += 1
        }
        .store(in: &cancellables)
        
        self.workoutServiceFake.sendBpmChange(bpm: 10)
        self.workoutServiceFake.sendBpmChange(bpm: 10)
        
        XCTAssertEqual(zoneChangeCalledCount, 1)
    }

    func testZoneTransmissionDeviceBeepCall() {
        self.workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = self.sut.activeHeartZoneSetting?.zones[0] else { return }
        
        self.sut.setState(state: HeartZoneActiveState(zone: sampleZone1, stateManager: self.sut, movement: .up, settingsService: self.settingsServiceFake))

        XCTAssertEqual(self.beepingServiceMock.handleDeviceBeepCallSequence.count, 1)
    }

    func testZoneTransmissionDeviceBeepToTargetZone() {
        self.workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = self.sut.activeHeartZoneSetting?.zones[0] else { return }
        guard let targetZone = self.sut.activeHeartZoneSetting?.zones[2] else { return }

        self.sut.setState(state: HeartZoneActiveState(zone: sampleZone1, stateManager: self.sut, movement: .up, settingsService: self.settingsServiceFake))
        self.sut.setState(state: HeartZoneActiveState(zone: targetZone, stateManager: self.sut, movement: .up, settingsService: self.settingsServiceFake))

        XCTAssertEqual(self.beepingServiceMock.handleDeviceBeepCallSequence[1].2, true)
    }
    
    func testZoneTransmissionDeviceBeepFromTargetZone() {
        self.workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = self.sut.activeHeartZoneSetting?.zones[0] else { return }
        guard let targetZone = self.sut.activeHeartZoneSetting?.zones[2] else { return }

        self.sut.setState(state: HeartZoneActiveState(zone: targetZone, stateManager: self.sut, movement: .down, settingsService: self.settingsServiceFake))
        self.sut.setState(state: HeartZoneActiveState(zone: sampleZone1, stateManager: self.sut, movement: .down, settingsService: self.settingsServiceFake))

        XCTAssertEqual(self.beepingServiceMock.handleDeviceBeepCallSequence[1].1, true)
    }
    
    func testZoneTransmissionDeviceBeepMovement() {
        self.workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = self.sut.activeHeartZoneSetting?.zones[0] else { return }
        
        self.sut.setState(state: HeartZoneActiveState(zone: sampleZone1, stateManager: self.sut, movement: .down, settingsService: self.settingsServiceFake))
        
        XCTAssertEqual(self.beepingServiceMock.handleDeviceBeepCallSequence[0].0, .down)
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
