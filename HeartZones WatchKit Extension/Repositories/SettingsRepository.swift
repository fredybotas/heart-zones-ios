//
//  SettingsRepository.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import Foundation

protocol ISettingsRepository {
    var heartZonesAlertEnabled: Bool { get set }
    var targetHeartZoneAlertEnabled: Bool { get set }
}

fileprivate let kHeartZonesAlertEnabledKey = "kHeartZonesAlertEnabledKey"
fileprivate let kTargetHeartZoneAlertEnabledKey = "kTargetHeartZoneAlertEnabledKey"

class SettingsRepository: ISettingsRepository {
    let defaults = UserDefaults.standard
    
    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    var heartZonesAlertEnabled: Bool {
        get {
            if isKeyPresentInUserDefaults(key: kHeartZonesAlertEnabledKey) {
                return defaults.bool(forKey: kHeartZonesAlertEnabledKey)
            }
            return true
        }
        
        set {
            defaults.set(newValue, forKey: kHeartZonesAlertEnabledKey)
        }
    }
    
    var targetHeartZoneAlertEnabled: Bool {
        get {
            if isKeyPresentInUserDefaults(key: kTargetHeartZoneAlertEnabledKey) {
                return defaults.bool(forKey: kTargetHeartZoneAlertEnabledKey)
            }
            return true
        }
        
        set {
            defaults.set(newValue, forKey: kTargetHeartZoneAlertEnabledKey)
        }
    }
}

class SettingsRepositoryCached: ISettingsRepository {
    let settingsRepository = SettingsRepository()
    
    private var heartZonesAlertEnabledInternal: Bool
    private var targetHeartZoneAlertEnabledInternal: Bool

    init() {
        heartZonesAlertEnabledInternal = settingsRepository.heartZonesAlertEnabled
        targetHeartZoneAlertEnabledInternal = settingsRepository.targetHeartZoneAlertEnabled
    }
    
    var heartZonesAlertEnabled: Bool {
        get {
            return heartZonesAlertEnabledInternal
        }
        
        set {
            settingsRepository.heartZonesAlertEnabled = newValue
            heartZonesAlertEnabledInternal = newValue
        }
    }
    
    var targetHeartZoneAlertEnabled: Bool {
        get {
            return targetHeartZoneAlertEnabledInternal
        }
        
        set {
            settingsRepository.targetHeartZoneAlertEnabled = newValue
            targetHeartZoneAlertEnabledInternal = newValue
        }
    }
}
