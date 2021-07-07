//
//  WorkoutControlsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 29/06/2021.
//

import Foundation

class WorkoutControlsViewModel: ObservableObject {

    private let workoutService: IWorkoutService
    
    //TODO: Connect to workoutService
    @Published private(set) var isRunning = true
    
    init(workoutService: IWorkoutService) {
        self.workoutService = workoutService
    }
    
    func pauseWorkout() {
        workoutService.pauseActiveWorkout()
        isRunning = false
    }
    
    func resumeWorkout() {
        workoutService.resumeActiveWorkout()
        isRunning = true
    }
    
    func stopWorkout() {
        workoutService.stopActiveWorkout()
        isRunning = false
    }

}
