//
//  WorkoutViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {

    @Published var isRunning: Bool = false
    @Published var bpm: Int = 0
    
    @Published var time: String = "1.2"
    
    @Published var energy: Int = 120
    @Published var distance: Double = 1.24

    @Published var currentPace: String = "2'34''"
    @Published var averagePace: String = "1'24''"

    
    let workoutService = WorkoutService()
    
    func startWorkout() {
        isRunning = true
        workoutService.startWorkout()
    }
    
    func pauseWorkout() {
        isRunning = false
    }
    
    func stopWorkout() {
        isRunning = false
    }
    
}
