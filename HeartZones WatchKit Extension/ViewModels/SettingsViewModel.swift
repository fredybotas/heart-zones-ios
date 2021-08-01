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
    //let distanceMetricOptions: [DistanceMetric] = [.km, .mi]
    
    @Published var heartZonesAlertEnabled: Bool
    @Published var targetHeartZoneAlertEnabled: Bool
    @Published var maxBpm: Int = 195
    //@Published var selectedDistanceMetric: DistanceMetric = .km
    
    static let kMinimumBpm = 60
    static let kMaximumBpm = 220

    private var settingsService: ISettingsService
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
    
        self.heartZonesAlertEnabled = settingsService.heartZonesAlertEnabled
        self.targetHeartZoneAlertEnabled = settingsService.targetHeartZoneAlertEnabled
        self.maxBpm = settingsService.maximumBpm
        
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
            .map({ $0 + SettingsViewModel.kMinimumBpm })
            .sink { [weak self] value in
                self?.settingsService.maximumBpm = value
            }
            .store(in: &cancellables)
    }
    

}
