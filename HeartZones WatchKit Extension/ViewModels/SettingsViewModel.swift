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
    @Published var heartZonesAlertEnabled: Bool
    @Published var targetHeartZoneAlertEnabled: Bool

    private var settingsRepository: ISettingsRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsRepository: ISettingsRepository) {
        self.settingsRepository = settingsRepository
    
        self.heartZonesAlertEnabled = settingsRepository.heartZonesAlertEnabled
        self.targetHeartZoneAlertEnabled = settingsRepository.targetHeartZoneAlertEnabled
        
        self.$heartZonesAlertEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsRepository.heartZonesAlertEnabled = value
            }
            .store(in: &cancellables)
        
        self.$targetHeartZoneAlertEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsRepository.targetHeartZoneAlertEnabled = value
            }
            .store(in: &cancellables)
    }
    

}
