//
//  ZoneStatistics.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//

import Foundation

struct ZoneStatistics {
    let timeInZones: [Int: TimeInterval]
    let percentagesInZones: [Int: Double]
}

protocol IZoneStaticticsCalculator {
    func calculateStatisticsFor(entries: [BpmEntry]) -> ZoneStatistics
    func calculatePercentageInTargetZone(entries: [BpmEntry]) -> Int
}

class ZoneStatisticsCalculator: IZoneStaticticsCalculator {
    let settingsService: ISettingsService

    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
    }

    func calculateStatisticsFor(entries _: [BpmEntry]) -> ZoneStatistics {
        return ZoneStatistics(timeInZones: [:], percentagesInZones: [:])
    }

    func calculatePercentageInTargetZone(entries _: [BpmEntry]) -> Int {
        return 0
    }
}
