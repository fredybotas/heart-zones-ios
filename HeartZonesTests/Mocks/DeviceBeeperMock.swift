//
//  DeviceBeeperMock.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 09/07/2021.
//

import Foundation
@testable import HeartZones_WatchKit_Extension

class DeviceBeeperMock: Beeper {
    var startHighRateAlertCalledCount = 0
    var startLowRateAlertCalledCount = 0
    
    var stopAlertingCalledCount = 0
    var changeZoneAlertCalledCount = 0
    var changeZoneAlertCallSequence = [HeartZonesSetting.HeartZoneMovement]()
    
    func startHighRateAlert() {
        startHighRateAlertCalledCount += 1
    }
    
    func stopAlertIfRunning() {
        stopAlertingCalledCount += 1
    }
    
    func startLowRateAlert() {
        startLowRateAlertCalledCount += 1
    }
    
    func changeZoneAlert(movement: HeartZonesSetting.HeartZoneMovement) {
        changeZoneAlertCalledCount += 1
        changeZoneAlertCallSequence.append(movement)
    }
}
