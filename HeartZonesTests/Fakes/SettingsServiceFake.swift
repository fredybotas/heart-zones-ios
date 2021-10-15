//
//  SettingsServiceFake.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 01/08/2021.
//

import Foundation

@testable import HeartZones_WatchKit_Extension

class SettingsServiceFake: ISettingsService {
    func resetHeartZoneSettings() {
        selectedHeartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting()
        maximumBpm = 195
        targetZoneId = 2
    }
    
    var targetZoneId: Int = 2
    var selectedHeartZoneSetting: HeartZonesSetting = HeartZonesSetting.getDefaultHeartZonesSetting()
    var heartZonesAlertEnabled: Bool = true
    var targetHeartZoneAlertEnabled: Bool = true
    var maximumBpm: Int = 195
    var selectedDistanceMetric: DistanceMetric = DistanceMetric.getDefault(metric: true)
    var selectedEnergyMetric: EnergyMetric = EnergyMetric.getDefault()
    var selectedSpeedMetric: SpeedMetric = SpeedMetric.getDefault()
}
