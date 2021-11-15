//
//  WorkoutControlsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 29/06/2021.
//

import Foundation
import Combine

class WorkoutControlsViewModel: ObservableObject {

    @Published var isRunning: Bool = false
    
    private let workoutService: IWorkoutService
    
    private var disposables = Set<AnyCancellable>()
        
    init(workoutService: IWorkoutService) {
        self.workoutService = workoutService
        
        workoutService
            .getWorkoutStatePublisher()
            .map({ $0 == .running})
            .sink { [weak self] val in
                self?.isRunning = val
            }
            .store(in: &disposables)
    }
    
    deinit {
        disposables.removeAll()
    }
    
    func pauseWorkout() {
        workoutService.pauseActiveWorkout()
    }
    
    func resumeWorkout() {
        workoutService.resumeActiveWorkout()
    }
    
    func stopWorkout() {
        workoutService.stopActiveWorkout()
    }

}
