//
//  SettingsRepositoryFake.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 31/07/2021.
//

import Foundation
@testable import HeartZones_WatchKit_Extension

class SettingsRepositoryFake: ISettingsRepository {
    var maximumBpm: Int? = 195
    var heartZonesAlertEnabled: Bool? = true
    var targetHeartZoneAlertEnabled: Bool? = true
    var selectedDistanceMetric: DistanceMetric? = DistanceMetric.getPossibleMetrics()[0]
    var selectedEnergyMetric: EnergyMetric? = EnergyMetric.getPossibleMetrics()[0]
    var selectedSpeedMetric: SpeedMetric? = SpeedMetric.getPossibleMetrics()[0]
}
