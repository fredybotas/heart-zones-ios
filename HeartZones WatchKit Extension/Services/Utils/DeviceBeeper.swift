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

fileprivate let kZoneALertInterval: TimeInterval = 4.0

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
        WKInterfaceDevice().play(.success)
    }
    
    func runOnceLowRateAlert() {
        WKInterfaceDevice().play(.failure)
    }
    
    func startHighRateAlert() {
        timerHighRate = Timer.TimerPublisher.init(interval: kZoneALertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { _ in
                self.runOnceHighRateAlert()
            }
    }
    
    func startLowRateAlert() {
        timerLowRate = Timer.TimerPublisher.init(interval: kZoneALertInterval, runLoop: .main, mode: .common)
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
