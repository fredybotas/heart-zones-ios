//
//  SettingsRepository.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import Foundation

protocol ISettingsRepository {
    var heartZonesAlertEnabled: Bool? { get set }
    var targetHeartZoneAlertEnabled: Bool? { get set }
    var maximumBpm: Int? { get set }
}

fileprivate let kHeartZonesAlertEnabledKey = "kHeartZonesAlertEnabledKey"
fileprivate let kTargetHeartZoneAlertEnabledKey = "kTargetHeartZoneAlertEnabledKey"
fileprivate let kMaximumBpm = "kMaximumBpm"

class SettingsRepository: ISettingsRepository {
    
    let defaults = UserDefaults.standard
    
    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    var heartZonesAlertEnabled: Bool? {
        get {
            if isKeyPresentInUserDefaults(key: kHeartZonesAlertEnabledKey) {
                return defaults.bool(forKey: kHeartZonesAlertEnabledKey)
            }
            return nil
        }
        set { defaults.set(newValue, forKey: kHeartZonesAlertEnabledKey) }
    }
    
    var targetHeartZoneAlertEnabled: Bool? {
        get {
            if isKeyPresentInUserDefaults(key: kTargetHeartZoneAlertEnabledKey) {
                return defaults.bool(forKey: kTargetHeartZoneAlertEnabledKey)
            }
            return nil
        }
        
        set {
            defaults.set(newValue, forKey: kTargetHeartZoneAlertEnabledKey)
        }
    }
    
    var maximumBpm: Int? {
        get {
            if isKeyPresentInUserDefaults(key: kMaximumBpm) {
                return defaults.integer(forKey: kMaximumBpm)
            }
            return nil
        }
        set { defaults.set(newValue, forKey: kMaximumBpm) }
    }
}

class SettingsRepositoryCached: ISettingsRepository {
    let settingsRepository = SettingsRepository()
    
    private var heartZonesAlertEnabledInternal: Bool?
    private var targetHeartZoneAlertEnabledInternal: Bool?
    private var maximumBpmInternal: Int?
  
    init() {
        heartZonesAlertEnabledInternal = settingsRepository.heartZonesAlertEnabled
        targetHeartZoneAlertEnabledInternal = settingsRepository.targetHeartZoneAlertEnabled
        maximumBpmInternal = settingsRepository.maximumBpm
    }
        
    var heartZonesAlertEnabled: Bool? {
        get {
            return heartZonesAlertEnabledInternal
        }
        
        set {
            settingsRepository.heartZonesAlertEnabled = newValue
            heartZonesAlertEnabledInternal = newValue
        }
    }
    
    var targetHeartZoneAlertEnabled: Bool? {
        get {
            return targetHeartZoneAlertEnabledInternal
        }
        
        set {
            settingsRepository.targetHeartZoneAlertEnabled = newValue
            targetHeartZoneAlertEnabledInternal = newValue
        }
    }
    
    var maximumBpm: Int? {
        get {
            return maximumBpmInternal
        }
    
        set {
            settingsRepository.maximumBpm = newValue
            maximumBpmInternal = newValue
        }
    }
    
}
