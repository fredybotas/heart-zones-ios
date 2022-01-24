//
//  ZoneStatistics.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//

import Foundation

struct ZoneStatistics {
    let timeInZones: [HeartZoneID: TimeInterval]
    let percentagesInZones: [HeartZoneID: UInt]
    let totalTime: TimeInterval
}

protocol IZoneStaticticsCalculator {
    func calculateStatisticsFor(segments: [BpmEntrySegment]) -> ZoneStatistics
    func calculatePercentageInTargetZone(segments: [BpmEntrySegment]) -> UInt
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

        var percentageInZonesDict = [HeartZoneID: UInt]()
        percentageInZones.forEach { percentageInZonesDict[$0.0] = $0.1 }
        return ZoneStatistics(
            timeInZones: timeInZonesDict,
            percentagesInZones: percentageInZonesDict,
            totalTime: getTotalTime(segments: segments)
        )
    }

    func calculatePercentageInTargetZone(segments: [BpmEntrySegment]) -> UInt {
        guard let targetZone = settingsService
            .selectedHeartZoneSetting
            .getZoneById(id: settingsService.targetZoneId)
        else {
            return 0
        }
        return getPercentageInZone(segments: segments, zone: targetZone)
    }

    private func getPercentageInZone(segments: [BpmEntrySegment], zone: HeartZone) -> UInt {
        let totalTime = getTotalTime(segments: segments)
        if totalTime.isZero || totalTime.isNaN || totalTime.isInfinite {
            return 0
        }
        return UInt(getTimeInZone(segments: segments, zone: zone) * 100 / totalTime)
    }

    private func getTimeInZone(segments: [BpmEntrySegment], zone: HeartZone) -> TimeInterval {
        let bpmRange = zone.getBpmRange(maxBpm: settingsService.maximumBpm)
        var totalTimeInZone = 0.0
        for segment in segments {
            var prevTimestamp = segment.startDate.timeIntervalSince1970
            guard let segmentEntries = segment.entries else { continue }
            for entry in segmentEntries {
                if bpmRange.contains(entry.value) {
                    totalTimeInZone += (entry.timestamp - prevTimestamp)
                }
                prevTimestamp = entry.timestamp
            }
            if let last = segmentEntries.last {
                if bpmRange.contains(last.value) {
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
