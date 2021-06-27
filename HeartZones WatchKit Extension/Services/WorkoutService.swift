//
//  WorkoutService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import HealthKit

class WorkoutService {

    let healthKit: HKHealthStore = HKHealthStore()
    var activeWorkout: Workout?
    
    func startWorkout(workoutType: WorkoutType) {
        if (activeWorkout != nil) {
            NSLog("Workout already exists")
            return
        }
        activeWorkout = Workout(healthKit: healthKit, type: workoutType)
    }
    
    func stopActiveWorkout() {
        guard let activeWorkout = activeWorkout else {
            NSLog("There is not running workout")
            return
        }
        activeWorkout.stop()
    }
    
    func pauseActiveWorkout() {
        activeWorkout?.pause()
    }
    
    func resumeActiveWorkout() {
        activeWorkout?.resume()
    }
}
