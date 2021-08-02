//
//  SettingsService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 01/08/2021.
//

import Foundation

protocol ISettingsService {
    var heartZonesAlertEnabled: Bool { get set }
    var targetHeartZoneAlertEnabled: Bool { get set }
    var maximumBpm: Int { get set }
}

let kDefaultAge = 25

class SettingsService: ISettingsService {
    var heartZonesAlertEnabled: Bool {
        get { self.settingsRepository.heartZonesAlertEnabled ?? true }
        set { self.settingsRepository.heartZonesAlertEnabled = newValue }
    }
    var targetHeartZoneAlertEnabled: Bool {
        get { self.settingsRepository.targetHeartZoneAlertEnabled ?? true }
        set { self.settingsRepository.targetHeartZoneAlertEnabled = newValue }
    }
    
    var maximumBpm: Int {
        get {
            if let maxBpm = settingsRepository.maximumBpm {
                return maxBpm
            } else {
                let age = healthKitService.age ?? kDefaultAge
                return HeartZonesSetting.getMaximumBpm(age: age)
            }
        }
        
        set {
            self.settingsRepository.maximumBpm = newValue
        }
    }
    
    private var settingsRepository: ISettingsRepository
    private var healthKitService: IHealthKitService
    
    init(settingsRepository: ISettingsRepository, healthKitService: IHealthKitService) {
        self.settingsRepository = settingsRepository
        self.healthKitService = healthKitService
    }
}
