//
//  BeepingServiceTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 19/07/2021.
//

import Foundation
import Combine
import XCTest

@testable import HeartZones_WatchKit_Extension

class BeepingServiceTests: XCTestCase {
    var sut: BeepingService!
    var deviceBeeperMock: DeviceBeeperMock!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        self.deviceBeeperMock = DeviceBeeperMock()
        self.sut = BeepingService(beeper: self.deviceBeeperMock)
        self.cancellables.removeAll()
    }
        
    func testBeepingUp() {
        self.sut.handleDeviceBeep(heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: false)
        
        XCTAssertEqual(deviceBeeperMock.runOnceHighRateAlertCalledCount, 1)
    }

    func testBeepingDown() {
        self.sut.handleDeviceBeep(heartZoneMovement: .down, fromTargetZone: false, enteredTargetZone: false)
        
        XCTAssertEqual(deviceBeeperMock.runOnceLowRateAlertCalledCount, 1)
    }

    func testEnteringTargetZone() {
        self.sut.handleDeviceBeep(heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: true)

        XCTAssertEqual(deviceBeeperMock.stopHighRateAlertCalledCount, 1)
        XCTAssertEqual(deviceBeeperMock.stopLowRateAlertCalledCount, 1)
    }

    func testLeavingTargetZoneDown() {
        self.sut.handleDeviceBeep(heartZoneMovement: .down, fromTargetZone: true, enteredTargetZone: false)

        XCTAssertEqual(deviceBeeperMock.startLowRateAlertCalledCount, 1)
    }

    func testLeavingTargetZoneUp() {
        self.sut.handleDeviceBeep(heartZoneMovement: .up, fromTargetZone: true, enteredTargetZone: false)

        XCTAssertEqual(deviceBeeperMock.startHighRateAlertCalledCount, 1)
    }
    
    func testZoneTransmissionUpWhenAlertBeeping() {
        self.deviceBeeperMock.startHighRateAlertCalledCount = 1
        self.sut.handleDeviceBeep(heartZoneMovement: .up, fromTargetZone: false, enteredTargetZone: false)
        
        XCTAssertEqual(deviceBeeperMock.runOnceHighRateAlertCalledCount, 0)
    }

    func testZoneTransmissionDownWhenAlertBeeping() {
        self.deviceBeeperMock.startLowRateAlertCalledCount = 1
        self.sut.handleDeviceBeep(heartZoneMovement: .down, fromTargetZone: false, enteredTargetZone: false)
            
        XCTAssertEqual(deviceBeeperMock.runOnceLowRateAlertCalledCount, 0)
    }
    
    func testStopAnyBeepingWhenLEavingTargetZone() {
        self.sut.handleDeviceBeep(heartZoneMovement: .down, fromTargetZone: true, enteredTargetZone: false)
            
        XCTAssertEqual(deviceBeeperMock.stopHighRateAlertCalledCount, 1)
        XCTAssertEqual(deviceBeeperMock.stopLowRateAlertCalledCount, 1)
    }
}
