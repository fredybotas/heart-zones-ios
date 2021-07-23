//
//  DeviceBeeper.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/07/2021.
//

import Foundation
import WatchKit
import Combine

protocol Beeper {
    var isLowRateAlertRunning: Bool { get }
    var isHighRateAlertRunning: Bool { get }
    
    func startHighRateAlert()
    func startLowRateAlert()
    func stopHighRateAlert()
    func stopLowRateAlert()
    
    func runOnceHighRateAlert()
    func runOnceLowRateAlert()
}

fileprivate let kZoneAlertInterval: TimeInterval = 4.0

class DeviceBeeper: Beeper {
    
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
    
    private var timerHighRate: AnyCancellable?
    private var timerLowRate: AnyCancellable?
    private var appStateChangeSubscriber: AnyCancellable?
    
    func runOnceHighRateAlert() {
        WKInterfaceDevice().play(.failure)
    }
    
    func runOnceLowRateAlert() {
        WKInterfaceDevice().play(.notification)
    }
    
    func startHighRateAlert() {
        self.runOnceHighRateAlert()
        timerHighRate = Timer.TimerPublisher.init(interval: kZoneAlertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { _ in
                self.runOnceHighRateAlert()
            }
    }
    
    func startLowRateAlert() {
        self.runOnceLowRateAlert()
        timerLowRate = Timer.TimerPublisher.init(interval: kZoneAlertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { _ in
                self.runOnceLowRateAlert()
            }
    }
    
    func stopHighRateAlert() {
        timerHighRate = nil
    }
    
    func stopLowRateAlert() {
        timerLowRate = nil
    }
    

    
}
