//
//  HeartZoneBarsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//
import Combine
import Foundation
import SwiftUI

struct HeartZoneBarViewModel: Hashable {
    var percentageString: String
    var percentage: Double
    var color: Color

    init(color: Color, percentage: UInt) {
        self.color = color
        self.percentage = Double(percentage) / 100.0
        percentageString = String(percentage) + "%"
    }
}

class HeartZoneBarsViewModel: ObservableObject {
    @Published var bars: [HeartZoneBarViewModel]

    let settingsService: ISettingsService
    let workoutService: IWorkoutService
    var timer: AnyCancellable?

    init(settingsService: ISettingsService, workoutService: IWorkoutService) {
        self.settingsService = settingsService
        self.workoutService = workoutService
        bars = settingsService
            .selectedHeartZoneSetting
            .zones
            .map {
                HeartZoneBarViewModel(color: $0.color.toColor(), percentage: 0)
            }
        timer = Timer
            .publish(every: 10, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.refreshBars()
                }
            })
    }

    private func refreshBars() {
        guard let statistics = workoutService.getActiveWorkoutZoneStatistics() else { return }

        DispatchQueue.main.async { [weak self, settingsService] in
            self?.bars = settingsService
                .selectedHeartZoneSetting
                .zones
                .map {
                    HeartZoneBarViewModel(
                        color: $0.color.toColor(),
                        percentage: statistics.percentagesInZones[$0.id] ?? 0
                    )
                }
        }
    }
}
