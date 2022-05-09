//
//  WorkoutSelectionViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import Combine

class WorkoutSelectionViewModel: ObservableObject {
    private var settingsService: ISettingsService
    private var cancellable: AnyCancellable?
    
    @Published var workoutTypes: [WorkoutType]
    
    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
        self.workoutTypes = settingsService.workoutsOrder
        setSubscribers()
    }
    
    func setSubscribers() {
        cancellable = $workoutTypes
            .dropFirst()
            .sink { [weak self] val in
                self?.settingsService.workoutsOrder = val
        }
    }
    
    func refreshWorkouts() {
        cancellable = nil
        workoutTypes = settingsService.workoutsOrder
        setSubscribers()
    }
}
