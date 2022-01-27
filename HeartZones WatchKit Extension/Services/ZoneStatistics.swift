//
//  ZoneStatistics.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//

import Foundation

struct ZoneStatistics {
    let timeInZones: [HeartZoneID: TimeInterval]
    let percentagesInZones: [HeartZoneID: Double]
    let totalTime: TimeInterval

    func getSmoothedPercentagesInZones() -> [HeartZoneID: UInt] {
        var smoothedPercentages = percentagesInZones
            .mapValues { UInt(($0 * 100).rounded()) }
        let sumDiff = 100 - Int(smoothedPercentages.reduce(0) { $0 + $1.1 })
        if smoothedPercentages.count < 2 {
            return smoothedPercentages
        }
        let secondLargestKey = smoothedPercentages.sorted(by: { $0.1 > $1.1 })[1].key
        var newValue = Int(smoothedPercentages[secondLargestKey] ?? 0) + sumDiff
        if newValue < 0 {
            newValue = 0
        }
        smoothedPercentages.updateValue(UInt(newValue), forKey: secondLargestKey)
        return smoothedPercentages
    }
}

protocol IZoneStaticticsCalculator {
    func calculateStatisticsFor(segments: [BpmEntrySegment]) -> ZoneStatistics
    func calculatePercentageInTargetZone(segments: [BpmEntrySegment]) -> Double
}

class ZoneStatisticsCalculator: IZoneStaticticsCalculator {
    private let settingsService: ISettingsService

    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
    }

    func calculateStatisticsFor(segments: [BpmEntrySegment]) -> ZoneStatistics {
        let timeInZones = settingsService
            .selectedHeartZoneSetting
            .zones
            .map { ($0.id, getTimeInZone(segments: segments, zone: $0)) }
        let percentageInZones = settingsService
            .selectedHeartZoneSetting
            .zones
            .map { ($0.id, getPercentageInZone(segments: segments, zone: $0)) }

        var timeInZonesDict = [HeartZoneID: TimeInterval]()
        timeInZones.forEach { timeInZonesDict[$0.0] = $0.1 }

        var percentageInZonesDict = [HeartZoneID: Double]()
        percentageInZones.forEach { percentageInZonesDict[$0.0] = $0.1 }
        return ZoneStatistics(
            timeInZones: timeInZonesDict,
            percentagesInZones: percentageInZonesDict,
            totalTime: getTotalTime(segments: segments)
        )
    }

    func calculatePercentageInTargetZone(segments: [BpmEntrySegment]) -> Double {
        guard let targetZone = settingsService
            .selectedHeartZoneSetting
            .getZoneById(id: settingsService.targetZoneId)
        else {
            return 0
        }
        return getPercentageInZone(segments: segments, zone: targetZone)
    }

    private func getPercentageInZone(segments: [BpmEntrySegment], zone: HeartZone) -> Double {
        let totalTime = getTotalTime(segments: segments)
        if totalTime.isZero || totalTime.isNaN || totalTime.isInfinite {
            return 0
        }
        return getTimeInZone(segments: segments, zone: zone) / totalTime
    }

    private func getTimeInZone(segments: [BpmEntrySegment], zone: HeartZone) -> TimeInterval {
        let bpmRange = zone.getBpmRange(maxBpm: settingsService.maximumBpm)
        let halfOpenRange = bpmRange.lowerBound ..< bpmRange.upperBound
        var totalTimeInZone = 0.0
        for segment in segments {
            var prevTimestamp = segment.startDate.timeIntervalSince1970
            guard let segmentEntries = segment.entries else { continue }
            for entry in segmentEntries {
                if halfOpenRange.contains(entry.value) {
                    totalTimeInZone += (entry.timestamp - prevTimestamp)
                }
                prevTimestamp = entry.timestamp
            }
            if let last = segmentEntries.last {
                if halfOpenRange.contains(last.value) {
                    totalTimeInZone += (segment.endDate.timeIntervalSince1970 - prevTimestamp)
                }
            }
        }
        return totalTimeInZone
    }

    private func getTotalTime(segments: [BpmEntrySegment]) -> TimeInterval {
        return segments
            .map { $0.endDate.timeIntervalSince1970 - $0.startDate.timeIntervalSince1970 }
            .reduce(0) { $0 + $1 }
    }
}
