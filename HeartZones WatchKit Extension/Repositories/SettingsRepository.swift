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
    var selectedDistanceMetric: DistanceMetric? { get set }
    var selectedEnergyMetric: EnergyMetric? { get set }
    var selectedSpeedMetric: SpeedMetric? { get set }
}

fileprivate let kHeartZonesAlertEnabledKey = "kHeartZonesAlertEnabledKey"
fileprivate let kTargetHeartZoneAlertEnabledKey = "kTargetHeartZoneAlertEnabledKey"
fileprivate let kMaximumBpm = "kMaximumBpm"
fileprivate let kSelectedDistanceMetric = "kSelectedDistanceMetric"
fileprivate let kSelectedEnergyMetric = "kSelectedEnergyMetric"
fileprivate let kSelectedSpeedMetric = "kSelectedSpeedMetric"

class SettingsRepository: ISettingsRepository {
    
    let defaults = UserDefaults.standard
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
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
    
    var selectedDistanceMetric: DistanceMetric? {
        get {
            if isKeyPresentInUserDefaults(key: kSelectedDistanceMetric) {
                guard let decodedJson = defaults.object(forKey: kSelectedDistanceMetric) as? Data else { return nil }
                guard let distanceMetric = try? self.decoder.decode(DistanceMetric.self, from: decodedJson) else { return nil }
                return distanceMetric
            }
            return nil
        }
        set {
            guard let metric = newValue else { return }
            guard let encodedMetric = try? encoder.encode(metric) else { return }
            defaults.set(encodedMetric, forKey: kSelectedDistanceMetric)
        }
    }
    
    var selectedEnergyMetric: EnergyMetric? {
        get {
            if isKeyPresentInUserDefaults(key: kSelectedEnergyMetric) {
                guard let decodedJson = defaults.object(forKey: kSelectedEnergyMetric) as? Data else { return nil }
                guard let energyMetric = try? self.decoder.decode(EnergyMetric.self, from: decodedJson) else { return nil }
                return energyMetric
            }
            return nil
        }
        set {
            guard let metric = newValue else { return }
            guard let encodedMetric = try? encoder.encode(metric) else { return }
            defaults.set(encodedMetric, forKey: kSelectedEnergyMetric)
        }
    }
    
    var selectedSpeedMetric: SpeedMetric? {
        get {
            if isKeyPresentInUserDefaults(key: kSelectedSpeedMetric) {
                guard let decodedJson = defaults.object(forKey: kSelectedSpeedMetric) as? Data else { return nil }
                guard let speedMetric = try? self.decoder.decode(SpeedMetric.self, from: decodedJson) else { return nil }
                return speedMetric
            }
            return nil
        }
        set {
            guard let metric = newValue else { return }
            guard let encodedMetric = try? encoder.encode(metric) else { return }
            defaults.set(encodedMetric, forKey: kSelectedSpeedMetric)
        }
    }

}

class SettingsRepositoryCached: ISettingsRepository {
    let settingsRepository = SettingsRepository()
    
    private var heartZonesAlertEnabledInternal: Bool?
    private var targetHeartZoneAlertEnabledInternal: Bool?
    private var maximumBpmInternal: Int?
    private var selectedDistanceMetricInternal: DistanceMetric?
    private var selectedEnergyMetricInternal: EnergyMetric?
    private var selectedSpeedMetricInternal: SpeedMetric?

    init() {
        heartZonesAlertEnabledInternal = settingsRepository.heartZonesAlertEnabled
        targetHeartZoneAlertEnabledInternal = settingsRepository.targetHeartZoneAlertEnabled
        maximumBpmInternal = settingsRepository.maximumBpm
        selectedDistanceMetricInternal = settingsRepository.selectedDistanceMetric
        selectedEnergyMetricInternal = settingsRepository.selectedEnergyMetric
        selectedSpeedMetricInternal = settingsRepository.selectedSpeedMetric
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
    
    var selectedDistanceMetric: DistanceMetric? {
        get {
            return selectedDistanceMetricInternal
        }
        
        set {
            selectedDistanceMetricInternal = newValue
            settingsRepository.selectedDistanceMetric = newValue
        }
    }
    
    var selectedEnergyMetric: EnergyMetric? {
        get {
            return selectedEnergyMetricInternal
        }
        
        set {
            selectedEnergyMetricInternal = newValue
            settingsRepository.selectedEnergyMetric = newValue
        }
    }
    
    var selectedSpeedMetric: SpeedMetric? {
        get {
            return selectedSpeedMetricInternal
        }
        
        set {
            selectedSpeedMetricInternal = newValue
            settingsRepository.selectedSpeedMetric = newValue
        }
    }
    
}
