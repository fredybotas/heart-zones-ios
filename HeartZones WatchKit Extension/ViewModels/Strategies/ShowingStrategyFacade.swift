//
//  ShowingStrategyFacade.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 07/11/2021.
//

import Foundation

class ShowingStrategyFacade {
    let energyShowingStrategy: IEnergyShowingStrategy
    let distanceShowingStrategy: IDistanceShowingStrategy
    
    init(settingsService: ISettingsService) {
        switch settingsService.selectedEnergyMetric.type {
        case .kj:
            self.energyShowingStrategy = EnergyKJShowingStrategy()
        case .kcal:
            self.energyShowingStrategy = EnergyKcalShowingStrategy()
        }
        
        switch settingsService.selectedDistanceMetric.type {
        case .km:
            switch settingsService.selectedSpeedMetric.type {
            case .pace:
                self.distanceShowingStrategy = MetricDistanceWithPaceShowingStrategy()
            case .speed:
                self.distanceShowingStrategy = MetricDistanceWithSpeedShowingStrategy()
            }
        case .mi:
            switch settingsService.selectedSpeedMetric.type {
            case .pace:
                self.distanceShowingStrategy = MilleageDistanceWithPaceShowingStrategy()
            case .speed:
                self.distanceShowingStrategy = MilleageDistanceWithSpeedShowingStrategy()
            }
        }
    }

}
