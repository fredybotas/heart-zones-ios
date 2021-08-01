//
//  BeepingService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 19/07/2021.
//

import Foundation
import WatchKit
import Combine

protocol IBeepingService {
    func handleDeviceBeep(heartZoneMovement: HeartZonesSetting.HeartZoneMovement, fromTargetZone: Bool, enteredTargetZone: Bool)
    func stopAnyBeeping()
}

class BeepingService: IBeepingService {
    private let beeper: BeepingManager
    private var settingsService: ISettingsService
    
    private var isAnyAlertRunning: Bool {
        get {
            return beeper.isHighRateAlertRunning || beeper.isLowRateAlertRunning
        }
    }
    
    private var appStateChangeSubscriber: AnyCancellable?

    init(beeper: BeepingManager, settingsService: ISettingsService) {
        self.beeper = beeper
        self.settingsService = settingsService
        
        initializeAppStateSubscriber()
    }
    
    private func initializeAppStateSubscriber() {
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            self.appStateChangeSubscriber = delegate.appStateChangePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] state in
                    if state == .foreground {
                        self?.stopAnyBeeping()
                    }
                })
        }
    }
    
    func stopAnyBeeping() {
        self.beeper.stopLowRateAlert()
        self.beeper.stopHighRateAlert()
    }
    
    func handleDeviceBeep(heartZoneMovement: HeartZonesSetting.HeartZoneMovement, fromTargetZone: Bool, enteredTargetZone: Bool) {
        if enteredTargetZone {
            self.stopAnyBeeping()
        }
        
        if fromTargetZone && settingsService.targetHeartZoneAlertEnabled {
            self.stopAnyBeeping()
            if heartZoneMovement == .up {
                self.beeper.startHighRateAlert()
            } else if heartZoneMovement == .down {
                self.beeper.startLowRateAlert()
            }
        } else if !isAnyAlertRunning && settingsService.heartZonesAlertEnabled {
            if heartZoneMovement == .up {
                self.beeper.runOnceHighRateAlert()
            } else if heartZoneMovement == .down {
                self.beeper.runOnceLowRateAlert()
            }
        }
    }
}
