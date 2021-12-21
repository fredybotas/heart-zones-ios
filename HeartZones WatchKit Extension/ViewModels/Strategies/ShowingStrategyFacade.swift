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
            energyShowingStrategy = EnergyKJShowingStrategy()
        case .kcal:
            energyShowingStrategy = EnergyKcalShowingStrategy()
        }

        switch settingsService.selectedDistanceMetric.type {
        case .km:
            switch settingsService.selectedSpeedMetric.type {
            case .pace:
                distanceShowingStrategy = MetricDistanceWithPaceShowingStrategy()
            case .speed:
                distanceShowingStrategy = MetricDistanceWithSpeedShowingStrategy()
            }
        case .mi:
            switch settingsService.selectedSpeedMetric.type {
            case .pace:
                distanceShowingStrategy = MilleageDistanceWithPaceShowingStrategy()
            case .speed:
                distanceShowingStrategy = MilleageDistanceWithSpeedShowingStrategy()
            }
        }
    }
}
