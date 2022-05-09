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
    var zonesCount: Int? { get set }
    var selectedDistanceMetric: DistanceMetric? { get set }
    var selectedEnergyMetric: EnergyMetric? { get set }
    var selectedSpeedMetric: SpeedMetric? { get set }
    var selectedMetricInFieldOne: WorkoutMetric? { get set }
    var selectedMetricInFieldTwo: WorkoutMetric? { get set }
    var selectedHeartZoneSetting: HeartZonesSetting? { get set }
    var workoutsOrder: [WorkoutType]? { get set }
}

private let kHeartZonesAlertEnabledKey = "kHeartZonesAlertEnabledKey"
private let kTargetHeartZoneAlertEnabledKey = "kTargetHeartZoneAlertEnabledKey"
private let kMaximumBpm = "kMaximumBpm"
private let kZonesCount = "kZonesCount"
private let kSelectedDistanceMetric = "kSelectedDistanceMetric"
private let kSelectedEnergyMetric = "kSelectedEnergyMetric"
private let kSelectedSpeedMetric = "kSelectedSpeedMetric"
private let kDefaultHeartZoneSetting = "kDefaultHeartZoneSetting"
private let kSelectedMetricInFieldOne = "kSelectedMetricInFieldOne"
private let kSelectedMetricInFieldTwo = "kSelectedMetricInFieldTwo"
private let kWorkoutsOrder = "kWorkoutsOrder"

class SettingsRepository: ISettingsRepository {
    let manager = UserDefaultsManager()

    var heartZonesAlertEnabled: Bool? {
        get { manager.get(key: kHeartZonesAlertEnabledKey) }
        set { manager.save(newValue, key: kHeartZonesAlertEnabledKey) }
    }

    var targetHeartZoneAlertEnabled: Bool? {
        get { manager.get(key: kTargetHeartZoneAlertEnabledKey) }
        set { manager.save(newValue, key: kTargetHeartZoneAlertEnabledKey) }
    }

    var maximumBpm: Int? {
        get { manager.get(key: kMaximumBpm) }
        set { manager.save(newValue, key: kMaximumBpm) }
    }

    var zonesCount: Int? {
        get { manager.get(key: kZonesCount) }
        set { manager.save(newValue, key: kZonesCount) }
    }

    var selectedDistanceMetric: DistanceMetric? {
        get { manager.get(key: kSelectedDistanceMetric) }
        set { manager.save(newValue, key: kSelectedDistanceMetric) }
    }

    var selectedEnergyMetric: EnergyMetric? {
        get { manager.get(key: kSelectedEnergyMetric) }
        set { manager.save(newValue, key: kSelectedEnergyMetric) }
    }

    var selectedSpeedMetric: SpeedMetric? {
        get { manager.get(key: kSelectedSpeedMetric) }
        set { manager.save(newValue, key: kSelectedSpeedMetric) }
    }

    var selectedMetricInFieldOne: WorkoutMetric? {
        get { manager.get(key: kSelectedMetricInFieldOne) }
        set { manager.save(newValue, key: kSelectedMetricInFieldOne) }
    }

    var selectedMetricInFieldTwo: WorkoutMetric? {
        get { manager.get(key: kSelectedMetricInFieldTwo) }
        set { manager.save(newValue, key: kSelectedMetricInFieldTwo) }
    }

    var selectedHeartZoneSetting: HeartZonesSetting? {
        get { manager.get(key: kDefaultHeartZoneSetting) }
        set { manager.save(newValue, key: kDefaultHeartZoneSetting) }
    }
    
    var workoutsOrder: [WorkoutType]? {
        get { manager.get(key: kWorkoutsOrder) }
        set { manager.save(newValue, key: kWorkoutsOrder) }
    }
}

class SettingsRepositoryCached: ISettingsRepository {
    let settingsRepository = SettingsRepository()

    private var heartZonesAlertEnabledInternal: Bool?
    private var targetHeartZoneAlertEnabledInternal: Bool?
    private var maximumBpmInternal: Int?
    private var zonesCountInternal: Int?
    private var selectedDistanceMetricInternal: DistanceMetric?
    private var selectedEnergyMetricInternal: EnergyMetric?
    private var selectedSpeedMetricInternal: SpeedMetric?
    private var selectedWorkoutUnitOneInternal: WorkoutMetric?
    private var selectedWorkoutUnitTwoInternal: WorkoutMetric?
    private var selectedHeartZoneSettingInternal: HeartZonesSetting?
    private var workoutsOrderInternal: [WorkoutType]?
    
    init() {
        heartZonesAlertEnabledInternal = settingsRepository.heartZonesAlertEnabled
        targetHeartZoneAlertEnabledInternal = settingsRepository.targetHeartZoneAlertEnabled
        maximumBpmInternal = settingsRepository.maximumBpm
        zonesCountInternal = settingsRepository.zonesCount
        selectedDistanceMetricInternal = settingsRepository.selectedDistanceMetric
        selectedEnergyMetricInternal = settingsRepository.selectedEnergyMetric
        selectedSpeedMetricInternal = settingsRepository.selectedSpeedMetric
        selectedHeartZoneSettingInternal = settingsRepository.selectedHeartZoneSetting
        selectedWorkoutUnitOneInternal = settingsRepository.selectedMetricInFieldOne
        selectedWorkoutUnitTwoInternal = settingsRepository.selectedMetricInFieldTwo
        workoutsOrderInternal = settingsRepository.workoutsOrder
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

    var zonesCount: Int? {
        get {
            return zonesCountInternal
        }

        set {
            settingsRepository.zonesCount = newValue
            zonesCountInternal = newValue
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

    var selectedMetricInFieldOne: WorkoutMetric? {
        get {
            return selectedWorkoutUnitOneInternal
        }

        set {
            selectedWorkoutUnitOneInternal = newValue
            settingsRepository.selectedMetricInFieldOne = newValue
        }
    }

    var selectedMetricInFieldTwo: WorkoutMetric? {
        get {
            return selectedWorkoutUnitTwoInternal
        }

        set {
            selectedWorkoutUnitTwoInternal = newValue
            settingsRepository.selectedMetricInFieldTwo = newValue
        }
    }

    var selectedHeartZoneSetting: HeartZonesSetting? {
        get {
            return selectedHeartZoneSettingInternal
        }

        set {
            selectedHeartZoneSettingInternal = newValue
            settingsRepository.selectedHeartZoneSetting = newValue
        }
    }
    
    var workoutsOrder: [WorkoutType]? {
        get {
            return workoutsOrderInternal
        }
        
        set {
            workoutsOrderInternal = newValue
            settingsRepository.workoutsOrder = newValue
        }
    }
}
