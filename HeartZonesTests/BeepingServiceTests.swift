//
//  BeepingServiceTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 19/07/2021.
//

import Combine
import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class BeepingServiceTests: XCTestCase {
    var sut: BeepingService!
    var deviceBeeperMock: DeviceBeeperMock!
    var settingsServiceFake: SettingsServiceFake!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        deviceBeeperMock = DeviceBeeperMock()
        settingsServiceFake = SettingsServiceFake()
        sut = BeepingService(
            beeper: deviceBeeperMock, settingsService: settingsServiceFake
        )
        cancellables.removeAll()
    }

    func testBeepingUp() {
        sut.handleDeviceBeep(
            heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.runOnceHighRateAlertCalledCount, 1)
    }

    func testBeepingUpWhenDisabled() {
        settingsServiceFake.heartZonesAlertEnabled = false
        sut.handleDeviceBeep(
            heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.runOnceHighRateAlertCalledCount, 0)
    }

    func testBeepingDown() {
        sut.handleDeviceBeep(
            heartZoneMovement: .down, fromTargetZone: false, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.runOnceLowRateAlertCalledCount, 1)
    }

    func testBeepingDownWhenDisabled() {
        settingsServiceFake.heartZonesAlertEnabled = false
        sut.handleDeviceBeep(
            heartZoneMovement: .down, fromTargetZone: false, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.runOnceLowRateAlertCalledCount, 0)
    }

    func testEnteringTargetZone() {
        sut.handleDeviceBeep(
            heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: true
        )

        XCTAssertEqual(deviceBeeperMock.stopHighRateAlertCalledCount, 1)
        XCTAssertEqual(deviceBeeperMock.stopLowRateAlertCalledCount, 1)
    }

    func testLeavingTargetZoneDown() {
        sut.handleDeviceBeep(
            heartZoneMovement: .down, fromTargetZone: true, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.startLowRateAlertCalledCount, 1)
    }

    func testLeavingTargetZoneUp() {
        sut.handleDeviceBeep(
            heartZoneMovement: .up, fromTargetZone: true, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.startHighRateAlertCalledCount, 1)
    }

    func testLeavingTargetZoneDownWhenAlertDisabled() {
        settingsServiceFake.targetHeartZoneAlertEnabled = false
        sut.handleDeviceBeep(
            heartZoneMovement: .down, fromTargetZone: true, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.startLowRateAlertCalledCount, 0)
    }

    func testLeavingTargetZoneUpWhenAlertDisabled() {
        settingsServiceFake.targetHeartZoneAlertEnabled = false
        sut.handleDeviceBeep(
            heartZoneMovement: .up, fromTargetZone: true, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.startHighRateAlertCalledCount, 0)
    }

    func testZoneTransmissionUpWhenAlertBeeping() {
        deviceBeeperMock.startHighRateAlertCalledCount = 1
        sut.handleDeviceBeep(
            heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.runOnceHighRateAlertCalledCount, 0)
    }

    func testZoneTransmissionDownWhenAlertBeeping() {
        deviceBeeperMock.startLowRateAlertCalledCount = 1
        sut.handleDeviceBeep(
            heartZoneMovement: .down, fromTargetZone: false, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.runOnceLowRateAlertCalledCount, 0)
    }

    func testStopAnyBeepingWhenLeavingTargetZone() {
        sut.handleDeviceBeep(
            heartZoneMovement: .down, fromTargetZone: true, enteredTargetZone: false
        )

        XCTAssertEqual(deviceBeeperMock.stopHighRateAlertCalledCount, 1)
        XCTAssertEqual(deviceBeeperMock.stopLowRateAlertCalledCount, 1)
    }
}
