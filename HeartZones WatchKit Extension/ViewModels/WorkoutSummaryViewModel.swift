//
//  WorkoutSummaryViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 28/10/2021.
//

import Combine
import Foundation
import SwiftUI

struct SummaryUnit: Hashable {
    let name: String
    let values: [String]
    let unit: String
    let color: Color?
}

struct SummaryRow: Hashable {
    let left: SummaryUnit?
    let right: SummaryUnit?
}

class WorkoutSummaryViewModel: ObservableObject {
    @Published var timeElapsed: String = "--:--,--"
    @Published var showSaveButton: Bool = false
    @Published var workoutType: String = "Loading"
    @Published var summaryUnits = [SummaryRow]()

    private var cancellables = Set<AnyCancellable>()
    private let summaryDataProcessingStrategy: ISummaryDataProcessingStrategy
    private let showingStrategyFacade: ShowingStrategyFacade
    private let workoutService: IWorkoutService
    private let settingsService: ISettingsService

    init(workoutService: IWorkoutService, settingsService: ISettingsService) {
        self.workoutService = workoutService
        self.settingsService = settingsService
        showingStrategyFacade = ShowingStrategyFacade(settingsService: settingsService)
        summaryDataProcessingStrategy = SummaryDataProcessingStrategy(
            showingStrategyFacade: showingStrategyFacade)

        summaryUnits = summaryDataProcessingStrategy.getDefault()

        self.workoutService
            .getActiveWorkoutSummaryPublisher()?
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] val in
                self?.setSummaryUnits(data: val)
            }
            .store(in: &cancellables)
    }

    private func setSummaryUnits(data: WorkoutSummaryData) {
        timeElapsed = data.elapsedTime.stringFromTimeInterval()
        workoutType = data.workoutType.name
        summaryUnits = summaryDataProcessingStrategy.processSummaryData(workoutSummaryData: data)
        showSaveButton = true
    }

    func saveWorkout() {
        workoutService.saveActiveWorkout()
    }

    func discardWorkout() {
        workoutService.discardActiveWorkout()
    }
}
