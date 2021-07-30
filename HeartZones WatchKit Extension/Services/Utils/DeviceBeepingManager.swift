//
//  DeviceBeeper.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/07/2021.
//

import Foundation
import WatchKit
import Combine

protocol BeepingManager {
    var isLowRateAlertRunning: Bool { get }
    var isHighRateAlertRunning: Bool { get }
    
    func startHighRateAlert()
    func startLowRateAlert()
    func stopHighRateAlert()
    func stopLowRateAlert()
    
    func runOnceHighRateAlert()
    func runOnceLowRateAlert()
}

fileprivate let kZoneAlertInterval: TimeInterval = 5.0

class DeviceBeepingManager: BeepingManager {
    
    var isLowRateAlertRunning: Bool {
        get {
            return timerLowRate != nil
        }
    }
    
    var isHighRateAlertRunning: Bool {
        get {
            return timerHighRate != nil
        }
    }

    private let beeper: IDeviceBeeper

    private var timerHighRate: AnyCancellable?
    private var timerLowRate: AnyCancellable?
    private var appStateChangeSubscriber: AnyCancellable?
    
    init(beeper: IDeviceBeeper) {
        self.beeper = beeper
    }
    
    func runOnceHighRateAlert() {
        self.beeper.runHighRateAlert()
    }
    
    func runOnceLowRateAlert() {
        self.beeper.runLowRateAlert()
    }
    
    func startHighRateAlert() {
        self.beeper.runHighRateAlert()
        timerHighRate = Timer.TimerPublisher.init(interval: kZoneAlertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { _ in
                self.beeper.runHighRateAlert()
            }
    }
    
    func startLowRateAlert() {
        self.beeper.runLowRateAlert()
        timerLowRate = Timer.TimerPublisher.init(interval: kZoneAlertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { _ in
                self.beeper.runLowRateAlert()
            }
    }
    
    func stopHighRateAlert() {
        timerHighRate = nil
    }
    
    func stopLowRateAlert() {
        timerLowRate = nil
    }
    

    
}
