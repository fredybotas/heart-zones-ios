//
//  DeviceBeeperMock.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 09/07/2021.
//

import Foundation
@testable import HeartZones_WatchKit_Extension

class DeviceBeeperMock: BeepingManager {
    var isLowRateAlertRunning: Bool {
        get {
            return startLowRateAlertCalledCount - stopLowRateAlertCalledCount > 0
        }
    }
    
    var isHighRateAlertRunning: Bool {
        get {
            return startHighRateAlertCalledCount - stopHighRateAlertCalledCount > 0
        }
    }
    
    var startHighRateAlertCalledCount = 0
    var startLowRateAlertCalledCount = 0
    var stopLowRateAlertCalledCount = 0
    var stopHighRateAlertCalledCount = 0
    var runOnceLowRateAlertCalledCount = 0
    var runOnceHighRateAlertCalledCount = 0
    
    func runOnceHighRateAlert() {
        runOnceHighRateAlertCalledCount += 1
    }
    
    func runOnceLowRateAlert() {
        runOnceLowRateAlertCalledCount += 1
    }
    
    func startHighRateAlert() {
        startHighRateAlertCalledCount += 1
    }
    
    func stopLowRateAlert() {
        stopLowRateAlertCalledCount += 1
    }
    
    func stopHighRateAlert() {
        stopHighRateAlertCalledCount += 1
    }
    
    func startLowRateAlert() {
        startLowRateAlertCalledCount += 1
    }
}
