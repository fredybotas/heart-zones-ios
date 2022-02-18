//
//  SettingsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import Combine
import Foundation
import SwiftUI

struct CustomNumberOption: Identifiable, Hashable, CustomStringConvertible {
    var id: Int
    var value: Int
    var description: String { String(value) }
}

class SettingsViewModel: ObservableObject {
    class Zone: ObservableObject, Identifiable, CustomStringConvertible, Hashable {
        static func == (lhs: SettingsViewModel.Zone, rhs: SettingsViewModel.Zone) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name && lhs.target && rhs.target
        }

        let id: Int
        let name: String
        let target: Bool

        var description: String { name }

        init(id: Int, name: String, target: Bool) {
            self.id = id
            self.name = name
            self.target = target
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(target)
        }
    }

    static let kMinimumBpm = 120
    static let kMaximumBpm = 220

    let distanceMetricOptions = DistanceMetric.getPossibleMetrics()
    let energyMetricOptions = EnergyMetric.getPossibleMetrics()
    let speedMetricOptions = SpeedMetric.getPossibleMetrics()
    let zonesCountOptions = HeartZonesSetting.getPossibleZoneCounts().map { CustomNumberOption(id: $0, value: $0) }
    let metricInFieldOneOptions = WorkoutMetric.getPossibleMetrics()
    let metricInFieldTwoOptions = WorkoutMetric.getPossibleMetrics()
    let maxBpmOptions = Array(kMinimumBpm ..< kMaximumBpm).map { CustomNumberOption(id: $0, value: $0) }

    private var settingsService: ISettingsService
    private var cancellables = Set<AnyCancellable>()

    // MARK: View

    @Published var heartZonesAlertEnabled: Bool
    @Published var targetHeartZoneAlertEnabled: Bool
    @Published var maxBpm: Int
    @Published var zonesCount: Int
    @Published var targetZone: Int
    @Published var zones: [Zone]

    @Published var selectedDistanceMetric: DistanceMetric
    @Published var selectedEnergyMetric: EnergyMetric
    @Published var selectedSpeedMetric: SpeedMetric

    @Published var selectedMetricInFieldOne: WorkoutMetric
    @Published var selectedMetricInFieldTwo: WorkoutMetric

    init(settingsService: ISettingsService) {
        self.settingsService = settingsService

        maxBpm = settingsService.maximumBpm
        zonesCount = settingsService.zonesCount
        targetZone = settingsService.targetZoneId
        zones = settingsService.selectedHeartZoneSetting.zones.map {
            Zone(id: $0.id, name: $0.name, target: $0.target)
        }

        heartZonesAlertEnabled = settingsService.heartZonesAlertEnabled
        targetHeartZoneAlertEnabled = settingsService.targetHeartZoneAlertEnabled
        selectedDistanceMetric = settingsService.selectedDistanceMetric
        selectedEnergyMetric = settingsService.selectedEnergyMetric
        selectedSpeedMetric = settingsService.selectedSpeedMetric

        selectedMetricInFieldOne = settingsService.selectedMetricInFieldOne
        selectedMetricInFieldTwo = settingsService.selectedMetricInFieldTwo

        initBindings()
    }

    // swiftlint:disable:next function_body_length
    func initBindings() {
        $targetZone
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.targetZoneId = value
            }
            .store(in: &cancellables)

        $heartZonesAlertEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.heartZonesAlertEnabled = value
            }
            .store(in: &cancellables)

        $targetHeartZoneAlertEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.targetHeartZoneAlertEnabled = value
            }
            .store(in: &cancellables)

        $maxBpm
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.maximumBpm = value
            }
            .store(in: &cancellables)

        $zonesCount
            .dropFirst()
            .sink { [weak self, settingsService] value in
                self?.settingsService.zonesCount = value
                self?.targetZone = settingsService.targetZoneId
                self?.zones = settingsService.selectedHeartZoneSetting.zones.map {
                    Zone(id: $0.id, name: $0.name, target: $0.target)
                }
            }
            .store(in: &cancellables)

        $selectedDistanceMetric
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedDistanceMetric = value
            }
            .store(in: &cancellables)

        $selectedEnergyMetric
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedEnergyMetric = value
            }
            .store(in: &cancellables)

        $selectedSpeedMetric
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedSpeedMetric = value
            }
            .store(in: &cancellables)

        $selectedMetricInFieldOne
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedMetricInFieldOne = value
            }
            .store(in: &cancellables)

        $selectedMetricInFieldTwo
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedMetricInFieldTwo = value
            }
            .store(in: &cancellables)
    }

    func resetHeartZoneSettings() {
        settingsService.resetHeartZoneSettings()

        cancellables.removeAll()

        maxBpm = settingsService.maximumBpm
        zonesCount = settingsService.zonesCount
        targetZone = settingsService.targetZoneId
        zones = settingsService.selectedHeartZoneSetting.zones.map {
            Zone(id: $0.id, name: $0.name, target: $0.target)
        }

        initBindings()
    }
}
