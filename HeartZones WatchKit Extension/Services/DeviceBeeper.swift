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
    func changeZoneAlert(movement: HeartZonesSetting.HeartZoneMovement)
}

class DeviceBeeper: Beeper {
    private var timer: AnyCancellable?
    private var appStateChangeSubscriber: AnyCancellable?

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
        WKInterfaceDevice().play(.directionUp)
    }
    
    private func runLowRateAlert() {
        WKInterfaceDevice().play(.directionDown)
    }
    
    func startHighRateAlert() {
        timer = Timer.TimerPublisher.init(interval: 3, runLoop: .main, mode: .common)
            .autoconnect()
            .sink{ _ in
                self.runHighRateAlert()
            }
    }
    
    func stopAlertIfRunning() {
        timer = nil
    }
    
    func startLowRateAlert() {
        timer = Timer.TimerPublisher.init(interval: 3, runLoop: .main, mode: .common)
            .autoconnect()
            .sink{ _ in
                self.runLowRateAlert()
            }
    }
    
    func changeZoneAlert(movement: HeartZonesSetting.HeartZoneMovement) {
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
