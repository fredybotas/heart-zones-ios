//
//  ReadOnlyBpmViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 20/02/2022.
//

import Combine
import Foundation
import SwiftUI

class ReadOnlyBpmViewModel: ObservableObject {
    struct Zone: Hashable {
        let lowerPercentage: CGFloat
        let upperPercentage: CGFloat
        let color: Color
    }

    @Published var bpmText: String = "--"
    @Published var bpmTextColor: Color = .gray
    @Published var zones: [Zone]
    @Published var zonesPercentage: CGFloat = 0.0

    private let healthKitService: IHealthKitService
    private let settingsService: ISettingsService

    private var cancellables = Set<AnyCancellable>()

    init(healthKitService: IHealthKitService, settingsService: ISettingsService) {
        self.healthKitService = healthKitService
        self.settingsService = settingsService
        zones = self.settingsService.selectedHeartZoneSetting
            .zones
            .map { Zone(lowerPercentage:
                CGFloat($0.bpmRangePercentage.lowerBound) / 100.0,
                upperPercentage: CGFloat($0.bpmRangePercentage.upperBound) / 100.0,
                color: $0.color.toColor())
            }

        self.healthKitService.startBpmPublishing()
        self.healthKitService
            .bpmDataPublisher?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] val in
                self?.setNewBpmValue(bpmEntry: val)
            }
            .store(in: &cancellables)
    }

    private func setNewBpmValue(bpmEntry: BpmEntry) {
        bpmTextColor = settingsService
            .selectedHeartZoneSetting
            .getZoneForBpm(bpm: bpmEntry.value, maxBpm: settingsService.maximumBpm)
            .color
            .toColor()
        bpmText = String(bpmEntry.value)
        let zonesPercentage = CGFloat(Double(bpmEntry.value) / Double(settingsService.maximumBpm))
        if zonesPercentage < 0 {
            self.zonesPercentage = 0.0
        } else if zonesPercentage >= 1.0 {
            self.zonesPercentage = 1.0
        } else {
            self.zonesPercentage = zonesPercentage
        }
    }

    deinit {
        self.healthKitService.stopBpmPublishing()
    }
}
