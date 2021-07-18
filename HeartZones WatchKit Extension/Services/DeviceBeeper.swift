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
    func startHighRateAlert()
    func stopAlertIfRunning()
    func startLowRateAlert()
    func runZoneChangeAlertIfNeeded(movement: HeartZonesSetting.HeartZoneMovement)
}

fileprivate let kZoneALertInterval: TimeInterval = 4.0

class DeviceBeeper: Beeper {
    private var timer: AnyCancellable?
    private var appStateChangeSubscriber: AnyCancellable?

    private var isHighRateAlertRunning = false
    private var isLowRateAlertRunning = false
    
    init() {
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            appStateChangeSubscriber = delegate.appStateChangePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] state in
                    if state == .foreground {
                        self?.stopAlertIfRunning()
                    }
                })
        }
    }
    
    private func runHighRateAlert() {
        WKInterfaceDevice().play(.retry)
    }
    
    private func runLowRateAlert() {
        WKInterfaceDevice().play(.failure)
    }
    
    func startHighRateAlert() {
        if isHighRateAlertRunning {
            return
        }
        timer = Timer.TimerPublisher.init(interval: kZoneALertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink{ _ in
                self.runHighRateAlert()
            }
        isHighRateAlertRunning = true
        isLowRateAlertRunning = false
    }
    
    func stopAlertIfRunning() {
        timer = nil
        isHighRateAlertRunning = false
        isLowRateAlertRunning = false
    }
    
    func startLowRateAlert() {
        if isLowRateAlertRunning {
            return
        }
        timer = Timer.TimerPublisher.init(interval: kZoneALertInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink{ _ in
                self.runLowRateAlert()
            }
        isLowRateAlertRunning = true
        isHighRateAlertRunning = false
    }
    
    func runZoneChangeAlertIfNeeded(movement: HeartZonesSetting.HeartZoneMovement) {
        if timer != nil {
            return
        }
        if movement == .up {
            runHighRateAlert()
        } else if movement == .down {
            runLowRateAlert()
        }
    }
}
