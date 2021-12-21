//
//  HeartZoneServiceTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 09/07/2021.
//

import Combine
import XCTest

@testable import HeartZones_WatchKit_Extension

class HeartZoneServiceTests: XCTestCase {
    let maxBpm = 190

    var workoutServiceFake: WorkoutServiceFake!
    var beepingServiceMock: BeepingServiceMock!
    var healthKitServiceMock: HealthKitServiceMock!
    var settingsServiceFake: SettingsServiceFake!

    var sut: HeartZoneService!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        workoutServiceFake = WorkoutServiceFake()
        beepingServiceMock = BeepingServiceMock()
        healthKitServiceMock = HealthKitServiceMock()
        settingsServiceFake = SettingsServiceFake()
        settingsServiceFake.maximumBpm = maxBpm

        sut = HeartZoneService(
            workoutService: workoutServiceFake, beepingService: beepingServiceMock,
            healthKitService: healthKitServiceMock, settingsService: settingsServiceFake
        )
        cancellables.removeAll()
    }

    func getBpmSampleFromHeartZone(zone: HeartZone) -> Int {
        return zone.getBpmRange(maxBpm: maxBpm).lowerBound + 1
    }

    func testInitialization() {
        workoutServiceFake.changeState(state: .notPresent)
        workoutServiceFake.sendBpmChange(bpm: 10)

        sut.getHeartZonePublisher().sink { _ in
            XCTAssert(false, "Zone should not be changed")
        }.store(in: &cancellables)
    }

    func testSetActiveHeartZoneSetting() {
        workoutServiceFake.changeState(state: .running)

        XCTAssertNotNil(sut.activeHeartZoneSetting)
    }

    func testZoneChange() {
        workoutServiceFake.changeState(state: .running)

        var firstZone: HeartZone?
        sut.getHeartZonePublisher().sink { zone in
            firstZone = zone
        }
        .store(in: &cancellables)

        guard let sampleZone1 = sut.activeHeartZoneSetting?.zones[0] else {
            XCTAssert(false, "Zone should be available")
            return
        }

        sut.setState(
            state: HeartZoneActiveState(
                zone: sampleZone1, stateManager: sut, movement: .up,
                settingsService: settingsServiceFake
            ))

        guard let firstZone = firstZone else {
            XCTAssert(false, "zone should be received")
            return
        }

        XCTAssertEqual(firstZone, sampleZone1)
    }

    func testZoneShouldChangeOnlyOnceWhenBpmInSameZone() {
        workoutServiceFake.changeState(state: .running)
        var zoneChangeCalledCount = 0
        sut.getHeartZonePublisher().sink { _ in
            zoneChangeCalledCount += 1
        }
        .store(in: &cancellables)

        workoutServiceFake.sendBpmChange(bpm: 10)
        workoutServiceFake.sendBpmChange(bpm: 10)

        XCTAssertEqual(zoneChangeCalledCount, 1)
    }

    func testZoneTransmissionDeviceBeepCall() {
        workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = sut.activeHeartZoneSetting?.zones[0] else { return }

        sut.setState(
            state: HeartZoneActiveState(
                zone: sampleZone1, stateManager: sut, movement: .up,
                settingsService: settingsServiceFake
            ))

        XCTAssertEqual(beepingServiceMock.handleDeviceBeepCallSequence.count, 1)
    }

    func testZoneTransmissionDeviceBeepToTargetZone() {
        workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = sut.activeHeartZoneSetting?.zones[0] else { return }
        guard let targetZone = sut.activeHeartZoneSetting?.zones[2] else { return }

        sut.setState(
            state: HeartZoneActiveState(
                zone: sampleZone1, stateManager: sut, movement: .up,
                settingsService: settingsServiceFake
            ))
        sut.setState(
            state: HeartZoneActiveState(
                zone: targetZone, stateManager: sut, movement: .up,
                settingsService: settingsServiceFake
            ))

        XCTAssertEqual(beepingServiceMock.handleDeviceBeepCallSequence[1].2, true)
    }

    func testZoneTransmissionDeviceBeepFromTargetZone() {
        workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = sut.activeHeartZoneSetting?.zones[0] else { return }
        guard let targetZone = sut.activeHeartZoneSetting?.zones[2] else { return }

        sut.setState(
            state: HeartZoneActiveState(
                zone: targetZone, stateManager: sut, movement: .down,
                settingsService: settingsServiceFake
            ))
        sut.setState(
            state: HeartZoneActiveState(
                zone: sampleZone1, stateManager: sut, movement: .down,
                settingsService: settingsServiceFake
            ))

        XCTAssertEqual(beepingServiceMock.handleDeviceBeepCallSequence[1].1, true)
    }

    func testZoneTransmissionDeviceBeepMovement() {
        workoutServiceFake.changeState(state: .running)

        guard let sampleZone1 = sut.activeHeartZoneSetting?.zones[0] else { return }

        sut.setState(
            state: HeartZoneActiveState(
                zone: sampleZone1, stateManager: sut, movement: .down,
                settingsService: settingsServiceFake
            ))

        XCTAssertEqual(beepingServiceMock.handleDeviceBeepCallSequence[0].0, .down)
    }

    func testContinousResubscriptionForZones() {
        workoutServiceFake.changeState(state: .running)
        var firstTimeCalled = false
        var completed = false
        sut
            .getHeartZonePublisher()
            .sink(
                receiveCompletion: { _ in
                    completed = true
                },
                receiveValue: { _ in
                    firstTimeCalled = true
                }
            ).store(in: &cancellables)

        workoutServiceFake.sendBpmChange(bpm: 10)
        XCTAssert(firstTimeCalled)
        workoutServiceFake.resetSubscribers()
        workoutServiceFake.changeState(state: .finished)
        XCTAssert(completed)

        workoutServiceFake.changeState(state: .notPresent)
        workoutServiceFake.changeState(state: .running)

        var secondTimeCalled = false
        sut.getHeartZonePublisher().sink { _ in
            secondTimeCalled = true
        }.store(in: &cancellables)
        workoutServiceFake.sendBpmChange(bpm: 10)

        XCTAssert(secondTimeCalled)
    }
}
