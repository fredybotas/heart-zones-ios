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
    var zonesCount: Int { get set }
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
        get { selectedHeartZoneSetting.zones.first { $0.target }?.id ?? 0 }
        set {
            selectedHeartZoneSetting.setTargetZone(targetZoneId: newValue)
        }
    }

    var selectedDistanceMetric: DistanceMetric {
        get {
            settingsRepository.selectedDistanceMetric
                ?? DistanceMetric.getDefault(metric: SettingsService.userPrefersMetric())
        }
        set { settingsRepository.selectedDistanceMetric = newValue }
    }

    var selectedEnergyMetric: EnergyMetric {
        get { settingsRepository.selectedEnergyMetric ?? EnergyMetric.getDefault() }
        set { settingsRepository.selectedEnergyMetric = newValue }
    }

    var selectedSpeedMetric: SpeedMetric {
        get { settingsRepository.selectedSpeedMetric ?? SpeedMetric.getDefault() }
        set { settingsRepository.selectedSpeedMetric = newValue }
    }

    var selectedMetricInFieldOne: WorkoutMetric {
        get {
            settingsRepository.selectedMetricInFieldOne ?? WorkoutMetric.getDefaultForFieldOne()
        }
        set { settingsRepository.selectedMetricInFieldOne = newValue }
    }

    var selectedMetricInFieldTwo: WorkoutMetric {
        get {
            settingsRepository.selectedMetricInFieldTwo ?? WorkoutMetric.getDefaultForFieldTwo()
        }
        set { settingsRepository.selectedMetricInFieldTwo = newValue }
    }

    var heartZonesAlertEnabled: Bool {
        get { settingsRepository.heartZonesAlertEnabled ?? true }
        set { settingsRepository.heartZonesAlertEnabled = newValue }
    }

    var targetHeartZoneAlertEnabled: Bool {
        get { settingsRepository.targetHeartZoneAlertEnabled ?? true }
        set { settingsRepository.targetHeartZoneAlertEnabled = newValue }
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
            settingsRepository.maximumBpm = newValue
        }
    }

    var zonesCount: Int {
        get { settingsRepository.zonesCount ?? HeartZonesSetting.getPossibleZoneCounts()[0] }
        set {
            settingsRepository.zonesCount = newValue
            settingsRepository.selectedHeartZoneSetting = nil
        }
    }

    var selectedHeartZoneSetting: HeartZonesSetting {
        get {
            settingsRepository.selectedHeartZoneSetting
                ?? HeartZonesSetting.getDefaultHeartZonesSetting(count: zonesCount)
        }
        set {
            settingsRepository.selectedHeartZoneSetting = newValue
            settingsRepository.zonesCount = newValue.zones.count
        }
    }

    private var settingsRepository: ISettingsRepository
    private var healthKitService: IHealthKitService

    init(settingsRepository: ISettingsRepository, healthKitService: IHealthKitService) {
        self.settingsRepository = settingsRepository
        self.healthKitService = healthKitService
    }

    func resetHeartZoneSettings() {
        settingsRepository.selectedHeartZoneSetting = nil
        settingsRepository.maximumBpm = nil
        settingsRepository.zonesCount = nil
    }

    static func userPrefersMetric() -> Bool {
        return ((Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem) as? Bool)
            ?? true
    }
}
