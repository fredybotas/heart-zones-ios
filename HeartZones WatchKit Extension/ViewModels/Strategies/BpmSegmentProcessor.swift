//
//  BpmSegmentProcessor.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 23/12/2021.
//

import Foundation

protocol IBpmSegmentProcessor {
    func processBpmEntries(bpmEntries: [BpmEntry]) -> [BpmSegment]
}

class BpmSegmentProcessor: IBpmSegmentProcessor {
    typealias EntryWithZone = (BpmEntry, HeartZone)

    private let settingsService: ISettingsService

    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
    }

    func processBpmEntries(bpmEntries: [BpmEntry]) -> [BpmSegment] {
        if bpmEntries.count >= 2 {
            let entriesWithZones = getZonesForBpmEntries(bpmEntries: bpmEntries)
            return createSegments(entriesWithZones: entriesWithZones)
        } else if bpmEntries.count == 1 {
            let zone = settingsService
                .selectedHeartZoneSetting
                .getZoneForBpm(bpm: bpmEntries[0].value, maxBpm: settingsService.maximumBpm)
            return [BpmSegment(color: zone.color, bpms: bpmEntries)]
        }
        return []
    }

    private func createSegments(entriesWithZones: [EntryWithZone]) -> [BpmSegment] {
        var result = [BpmSegment]()
        var i = 1
        var currentSegmentEntries = [BpmEntry]()
        while i != entriesWithZones.count {
            currentSegmentEntries.append(entriesWithZones[i - 1].0)
            if entriesWithZones[i - 1].1.id != entriesWithZones[i].1.id {
                let movementUp = entriesWithZones[i - 1].1.id < entriesWithZones[i].1.id
                var segment = BpmSegment(color: entriesWithZones[i - 1].1.color, bpms: currentSegmentEntries)
                let marginBpmValueForSegment = movementUp ?
                    entriesWithZones[i - 1].1.getZoneMaxBpm(maxBpm: settingsService.maximumBpm) :
                    entriesWithZones[i - 1].1.getZoneMinBpm(maxBpm: settingsService.maximumBpm)
                let segmentInterpolatedTimestamp = BpmSegmentProcessor.getInterpolatedTimestamp(
                    lower: entriesWithZones[i - 1].0,
                    upper: entriesWithZones[i].0,
                    bpmToInterpolate: marginBpmValueForSegment
                )
                segment.appendBpmEntry(entry:
                    BpmEntry(
                        value: marginBpmValueForSegment,
                        timestamp: segmentInterpolatedTimestamp
                    )
                )
                result.append(segment)
                result.append(contentsOf: getMarginalSegments(
                    first: entriesWithZones[i - 1],
                    second: entriesWithZones[i]
                ))
                let marginBpmForNextSegment = movementUp ?
                    entriesWithZones[i].1.getZoneMinBpm(maxBpm: settingsService.maximumBpm) :
                    entriesWithZones[i].1.getZoneMaxBpm(maxBpm: settingsService.maximumBpm)
                let initialEntry = BpmEntry(value: marginBpmForNextSegment,
                                            timestamp: BpmSegmentProcessor.getInterpolatedTimestamp(
                                                lower: entriesWithZones[i - 1].0,
                                                upper: entriesWithZones[i].0,
                                                bpmToInterpolate: marginBpmForNextSegment
                                            ))
                currentSegmentEntries = [initialEntry]
            }
            i += 1
        }
        currentSegmentEntries.append(entriesWithZones.last!.0)
        let segment = BpmSegment(color: entriesWithZones.last!.1.color, bpms: currentSegmentEntries)
        result.append(segment)
        return result
    }

    private func getMarginalSegments(first: EntryWithZone, second: EntryWithZone) -> [BpmSegment] {
        if abs(first.1.id - second.1.id) == 1 {
            return []
        }
        var result = [BpmSegment]()
        var id = first.1.id
        id += id > second.1.id ? -1 : 1
        let isMovementUp = first.1.id < second.1.id
        while id != second.1.id {
            if let zone = settingsService.selectedHeartZoneSetting.getZoneById(id: id) {
                var bpms = [BpmEntry]()
                bpms.append(
                    BpmEntry(
                        value: isMovementUp ?
                            zone.getZoneMinBpm(maxBpm: settingsService.maximumBpm) :
                            zone.getZoneMaxBpm(maxBpm: settingsService.maximumBpm),
                        timestamp: BpmSegmentProcessor.getInterpolatedTimestamp(
                            lower: first.0,
                            upper: second.0,
                            bpmToInterpolate: isMovementUp ?
                                zone.getZoneMinBpm(maxBpm: settingsService.maximumBpm) :
                                zone.getZoneMaxBpm(maxBpm: settingsService.maximumBpm)
                        )
                    )
                )
                bpms.append(
                    BpmEntry(
                        value: isMovementUp ?
                            zone.getZoneMaxBpm(maxBpm: settingsService.maximumBpm) :
                            zone.getZoneMinBpm(maxBpm: settingsService.maximumBpm),
                        timestamp: BpmSegmentProcessor.getInterpolatedTimestamp(
                            lower: first.0,
                            upper: second.0,
                            bpmToInterpolate: isMovementUp ?
                                zone.getZoneMaxBpm(maxBpm: settingsService.maximumBpm) :
                                zone.getZoneMinBpm(maxBpm: settingsService.maximumBpm)
                        )
                    ))
                let segment = BpmSegment(color: zone.color, bpms: bpms)
                result.append(segment)
            }
            id += id > second.1.id ? -1 : 1
        }
        return result
    }

    static func getInterpolatedTimestamp(lower: BpmEntry, upper: BpmEntry, bpmToInterpolate: Int) -> TimeInterval {
        let ratio = Double(bpmToInterpolate - lower.value) / Double(upper.value - lower.value)
        return (Double(upper.timestamp - lower.timestamp) * ratio) + lower.timestamp
    }

    private func getZonesForBpmEntries(bpmEntries: [BpmEntry]) -> [(BpmEntry, HeartZone)] {
        return bpmEntries
            .map {
                ($0, settingsService
                    .selectedHeartZoneSetting
                    .getZoneForBpm(bpm: $0.value, maxBpm: settingsService.maximumBpm))
            }
    }
}
