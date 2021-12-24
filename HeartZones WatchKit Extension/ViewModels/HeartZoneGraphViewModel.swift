//
//  HeartZoneGraphViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/11/2021.
//

import Combine
import Foundation
import SwiftUI

struct BpmSegment: Hashable {
    let color: HeartZone.Color
    var bpms: [BpmEntry]

    mutating func prependBpmEntry(entry: BpmEntry) {
        bpms.insert(entry, at: 0)
    }

    mutating func appendBpmEntry(entry: BpmEntry) {
        bpms.append(entry)
    }
}

struct ZoneMargin: Hashable {
    let name: String
    let bpm: Int
}

class HeartZoneGraphViewModel: ObservableObject {
    var bpmTimeInterval: TimeInterval = 0
    var bpmMinTimestamp: TimeInterval = 0
    var bpmMaxTimestamp: TimeInterval = 0
    var bpmMin: Int = 0
    var bpmMax: Int = 0
    let zoneMargins: [ZoneMargin]

    @Published var bpms: [BpmSegment] = []
    @Published var bpmTimeDuration: String = "--"
    @Published var end: CGFloat = .zero

    private var refreshTimer: AnyCancellable?
    private let healthKit: IHealthKitService
    private var bpmCancellable: AnyCancellable?
    private let segmentProcessor: BpmSegmentProcessor

    init(healthKitService: IHealthKitService, settingsService: ISettingsService) {
        healthKit = healthKitService
        segmentProcessor = BpmSegmentProcessor(settingsService: settingsService)
        zoneMargins = settingsService
            .selectedHeartZoneSetting
            .zones
            .map { ZoneMargin(name: $0.name, bpm: $0.getZoneMaxBpm(maxBpm: settingsService.maximumBpm)) }
        refreshTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getBpmData()
            }
        getBpmData()
    }

    private func getBpmData() {
        bpmCancellable = healthKit
            .getBpmData(startDate: Date(timeIntervalSinceNow: -3 * 60) as NSDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] val in
                self?.processBpmValues(bpmEntries: val)
            })
    }

    private func processBpmValues(bpmEntries: [BpmEntry]) {
        bpmTimeInterval = (bpmEntries.last?.timestamp ?? 0) - (bpmEntries.first?.timestamp ?? 0)
        bpmMinTimestamp = bpmEntries.first?.timestamp ?? 0
        bpmMaxTimestamp = bpmEntries.last?.timestamp ?? 0
        bpmMin = bpmEntries.min(by: { $0.value < $1.value })?.value ?? 0
        bpmMax = bpmEntries.max(by: { $0.value < $1.value })?.value ?? 0
        bpms = segmentProcessor.processBpmEntries(bpmEntries: bpmEntries)

        var min: TimeInterval = Double.infinity
        var max: TimeInterval = -Double.infinity
        if bpmEntries.isEmpty {
            bpmTimeDuration = "--"
            return
        }
        for entry in bpmEntries {
            if entry.timestamp < min {
                min = entry.timestamp
            }
            if entry.timestamp > max {
                max = entry.timestamp
            }
        }
        let interval = max - min
        if interval >= 60 {
            bpmTimeDuration = String(Int((interval / 60).rounded())) + "m"
        } else {
            bpmTimeDuration = String(Int(interval)) + "s"
        }
    }
}
