//
//  SettingsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import Foundation
import Combine
import SwiftUI

struct BpmViewModel: Identifiable, Hashable, CustomStringConvertible {
    var id: Int
    var value: Int
    var description: String { get { String(value) } }
}

class SettingsViewModel: ObservableObject {
    class Zone: ObservableObject, Identifiable, CustomStringConvertible, Hashable {
        static func == (lhs: SettingsViewModel.Zone, rhs: SettingsViewModel.Zone) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name && lhs.target && rhs.target
        }
        
        let id: Int
        let name: String
        let target: Bool
        
        var description: String { get { name } }
        
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
    let zonesCountOptions = HeartZonesSetting.getPossibleZoneCounts()
    let metricInFieldOneOptions = WorkoutMetric.getPossibleMetrics()
    let metricInFieldTwoOptions = WorkoutMetric.getPossibleMetrics()
    let maxBpmOptions = Array.init(kMinimumBpm..<kMaximumBpm).map { BpmViewModel(id: $0, value: $0) }

    private var settingsService: ISettingsService
    private var cancellables = Set<AnyCancellable>()

    // MARK: View
    @Published var heartZonesAlertEnabled: Bool
    @Published var targetHeartZoneAlertEnabled: Bool
    @Published var maxBpm: Int
    @Published var targetZone: Int
    @Published var zones: [Zone]
    
    @Published var selectedDistanceMetric: DistanceMetric
    @Published var selectedEnergyMetric: EnergyMetric
    @Published var selectedSpeedMetric: SpeedMetric
    
    @Published var selectedMetricInFieldOne: WorkoutMetric
    @Published var selectedMetricInFieldTwo: WorkoutMetric
    
    init(settingsService: ISettingsService) {
        self.settingsService = settingsService

        self.maxBpm = settingsService.maximumBpm
        self.targetZone = settingsService.targetZoneId
        self.zones = settingsService.selectedHeartZoneSetting.zones.map { Zone(id: $0.id, name: $0.name, target: $0.target) }
        
        self.heartZonesAlertEnabled = settingsService.heartZonesAlertEnabled
        self.targetHeartZoneAlertEnabled = settingsService.targetHeartZoneAlertEnabled
        self.selectedDistanceMetric = settingsService.selectedDistanceMetric
        self.selectedEnergyMetric = settingsService.selectedEnergyMetric
        self.selectedSpeedMetric = settingsService.selectedSpeedMetric

        self.selectedMetricInFieldOne = settingsService.selectedMetricInFieldOne
        self.selectedMetricInFieldTwo = settingsService.selectedMetricInFieldTwo
        
        initBindings()
    }
    
    func initBindings() {
        self.$targetZone
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.targetZoneId = value
            }
            .store(in: &cancellables)

        self.$heartZonesAlertEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.heartZonesAlertEnabled = value
            }
            .store(in: &cancellables)
        
        self.$targetHeartZoneAlertEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.targetHeartZoneAlertEnabled = value
            }
            .store(in: &cancellables)
        
        self.$maxBpm
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.maximumBpm = value
            }
            .store(in: &cancellables)
        
        self.$selectedDistanceMetric
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedDistanceMetric = value
            }
            .store(in: &cancellables)
        
        self.$selectedEnergyMetric
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedEnergyMetric = value
            }
            .store(in: &cancellables)
        
        self.$selectedSpeedMetric
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedSpeedMetric = value
            }
            .store(in: &cancellables)
        
        self.$selectedMetricInFieldOne
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedMetricInFieldOne = value
            }
            .store(in: &cancellables)
        
        self.$selectedMetricInFieldTwo
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.selectedMetricInFieldTwo = value
            }
            .store(in: &cancellables)
    }
    
    func resetHeartZoneSettings() {
        settingsService.resetHeartZoneSettings()
    
        cancellables.removeAll()
        
        self.maxBpm = settingsService.maximumBpm
        self.targetZone = settingsService.targetZoneId
        self.zones = settingsService.selectedHeartZoneSetting.zones.map { Zone(id: $0.id, name: $0.name, target: $0.target) }

        initBindings()
    }
}
