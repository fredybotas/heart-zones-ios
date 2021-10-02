//
//  SettingsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    let distanceMetricOptions = DistanceMetric.getPossibleMetrics()
    let energyMetricOptions = EnergyMetric.getPossibleMetrics()
    let speedMetricOptions = SpeedMetric.getPossibleMetrics()
    let zonesCountOptions = HeartZonesSetting.getPossibleZoneCounts()
    
    static let kMinimumBpm = 60
    static let kMaximumBpm = 220

    private var settingsService: ISettingsService
    private var cancellables = Set<AnyCancellable>()

    // MARK: View
    @Published var heartZonesAlertEnabled: Bool
    @Published var targetHeartZoneAlertEnabled: Bool
    @Published var maxBpm: Int
    @Published var zonesCount: Int
    @Published var targetZone: String
    
    @Published var selectedDistanceMetric: DistanceMetric
    @Published var selectedEnergyMetric: EnergyMetric
    @Published var selectedSpeedMetric: SpeedMetric

    @Published var selectedHeartZoneSetting: HeartZonesSetting
    
    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
    
        self.heartZonesAlertEnabled = settingsService.heartZonesAlertEnabled
        self.targetHeartZoneAlertEnabled = settingsService.targetHeartZoneAlertEnabled
        self.maxBpm = settingsService.maximumBpm
        self.selectedDistanceMetric = settingsService.selectedDistanceMetric
        self.selectedEnergyMetric = settingsService.selectedEnergyMetric
        self.selectedSpeedMetric = settingsService.selectedSpeedMetric
        
        let heartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting()
        self.selectedHeartZoneSetting = heartZoneSetting
        self.zonesCount = heartZoneSetting.zonesCount
        self.targetZone = heartZoneSetting.targetZoneName
        
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
            .debounce(for: 0.5, scheduler: RunLoop.main)
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
    }
    

}
