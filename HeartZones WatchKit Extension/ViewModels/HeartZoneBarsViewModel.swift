//
//  HeartZoneBarsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//
import Foundation
import SwiftUI

struct HeartZoneBarViewModel: Hashable {
    var percentageString: String = "0%"
    var percentage: Double = 1.0
    var color: Color

    init(color: Color) {
        self.color = color
    }
}

class HeartZoneBarsViewModel: ObservableObject {
    var bars: [HeartZoneBarViewModel]
    let settingsService: ISettingsService

    init(settingsService: ISettingsService) {
        self.settingsService = settingsService

        bars = settingsService
            .selectedHeartZoneSetting
            .zones
            .map {
                HeartZoneBarViewModel(color: $0.color.toColor())
            }
    }
}
