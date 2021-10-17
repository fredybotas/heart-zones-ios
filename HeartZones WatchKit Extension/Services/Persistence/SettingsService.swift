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
    var selectedDistanceMetric: DistanceMetric { get set }
    var selectedEnergyMetric: EnergyMetric { get set }
    var selectedSpeedMetric: SpeedMetric { get set }
    var selectedMetricInFieldOne: WorkoutMetric { get set }
    var selectedMetricInFieldTwo: WorkoutMetric { get set }
    var selectedHeartZoneSetting: HeartZonesSetting { get set }
    var targetZoneId: Int { get set }
    
    func resetHeartZoneSettings()
}

let kDefaultAge = 25
class SettingsService: ISettingsService {
    var targetZoneId: Int {
        get { self.selectedHeartZoneSetting.zones.first { $0.target }?.id ?? 0 }
        set {
            selectedHeartZoneSetting.setTargetZone(targetZoneId: newValue)
        }
    }
    
    var selectedDistanceMetric: DistanceMetric {
        get { self.settingsRepository.selectedDistanceMetric ?? DistanceMetric.getDefault(metric: SettingsService.userPrefersMetric()) }
        set { self.settingsRepository.selectedDistanceMetric = newValue }
    }
    var selectedEnergyMetric: EnergyMetric {
        get { self.settingsRepository.selectedEnergyMetric ?? EnergyMetric.getDefault() }
        set { self.settingsRepository.selectedEnergyMetric = newValue }
    }
    var selectedSpeedMetric: SpeedMetric {
        get { self.settingsRepository.selectedSpeedMetric ?? SpeedMetric.getDefault() }
        set { self.settingsRepository.selectedSpeedMetric = newValue }
    }
    var selectedMetricInFieldOne: WorkoutMetric {
        get { self.settingsRepository.selectedMetricInFieldOne ?? WorkoutMetric.getDefaultForFieldOne() }
        set { self.settingsRepository.selectedMetricInFieldOne = newValue }
    }
    var selectedMetricInFieldTwo: WorkoutMetric {
        get { self.settingsRepository.selectedMetricInFieldTwo ?? WorkoutMetric.getDefaultForFieldTwo() }
        set { self.settingsRepository.selectedMetricInFieldTwo = newValue }
    }
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
    
    var selectedHeartZoneSetting: HeartZonesSetting {
        get { self.settingsRepository.selectedHeartZoneSetting ?? HeartZonesSetting.getDefaultHeartZonesSetting() }
        set { self.settingsRepository.selectedHeartZoneSetting = newValue
            print(newValue)
        }
    }
    
    private var settingsRepository: ISettingsRepository
    private var healthKitService: IHealthKitService
    
    init(settingsRepository: ISettingsRepository, healthKitService: IHealthKitService) {
        self.settingsRepository = settingsRepository
        self.healthKitService = healthKitService
    }
    
    func resetHeartZoneSettings() {
        self.settingsRepository.selectedHeartZoneSetting = nil
        self.settingsRepository.maximumBpm = nil
    }

    static func userPrefersMetric() -> Bool {
        return ((Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem) as? Bool) ?? true
    }
}