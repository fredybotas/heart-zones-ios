//
//  WorkoutSummaryViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 28/10/2021.
//

import Foundation
import SwiftUI
import Combine

struct SummaryUnit: Hashable {
    let name: String
    let values: [String]
    let unit: String
//    let color: Color?
}

struct SummaryRow: Hashable {
    let left: SummaryUnit?
    let right: SummaryUnit?
}

class WorkoutSummaryViewModel: ObservableObject {
    @Published var timeElapsed: String = "00:00,00"
    @Published var workoutType: String = "--"
    
    @Published var summaryUnits = [SummaryRow]()

    private var cancellables = Set<AnyCancellable>()
    private let summaryDataProcessingStrategy: ISummaryDataProcessingStrategy
    private let showingStrategyFacade: ShowingStrategyFacade
    private let workoutService: IWorkoutService
    private let settingsService: ISettingsService
    
    
    init(workoutService: IWorkoutService, settingsService: ISettingsService) {
        self.workoutService = workoutService
        self.settingsService = settingsService
        self.showingStrategyFacade = ShowingStrategyFacade(settingsService: settingsService)
        self.summaryDataProcessingStrategy = SummaryDataProcessingStrategy(showingStrategyFacade: showingStrategyFacade)

        self.summaryUnits = self.summaryDataProcessingStrategy.getDefault()
        
        self.workoutService
            .getActiveWorkoutSummaryPublisher()?
            .compactMap({ $0 })
            .sink { [weak self] val in
                self?.setSummaryUnits(data: val)
            }
            .store(in: &cancellables)
    }
    
    private func setSummaryUnits(data: WorkoutSummaryData) {
        timeElapsed = data.elapsedTime.stringFromTimeInterval()
        workoutType = data.workoutType.name
        summaryUnits = summaryDataProcessingStrategy.processSummaryData(workoutSummaryData: data)
    }
    
    func saveWorkout() {
        workoutService.saveActiveWorkout()
    }
    
    func discardWorkout() {
        workoutService.discardActiveWorkout()
    }
}
