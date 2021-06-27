//
//  WorkoutViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {

    @Published var isRunning: Bool = true
    
    @Published var bpm: String = "-- bpm"    
    @Published var bpmCircleColor = Color.green
    @Published var bpmCircleRatio = 0.25
    
    @Published var time: String = "--:--,--"
    @Published var energy: String = "-- kcal"
    @Published var distance: String = "-- km"
    @Published var currentPace: String = "--'--''"
    @Published var averagePace: String = "--'--''"


    let workoutService: IWorkoutService = WorkoutService()
    //TODO: Get correct age
    let heartZoneService: HeartZoneService = HeartZoneService(age: 25)
    
    init(workoutType: WorkoutType) {
        workoutService.startWorkout(workoutType: workoutType)
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
