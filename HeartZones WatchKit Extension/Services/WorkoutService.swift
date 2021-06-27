//
//  WorkoutService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import HealthKit
import os

protocol IWorkoutService {
    func startWorkout(workoutType: WorkoutType)
    func stopActiveWorkout()
    func pauseActiveWorkout()
    func resumeActiveWorkout()
}

class WorkoutService: IWorkoutService {
    private let healthKit: HKHealthStore = HKHealthStore()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "workout_service")
    private var activeWorkout: Workout?
    
    func startWorkout(workoutType: WorkoutType) {
        if (activeWorkout != nil) {
            logger.info("Workout already exists")
            return
        }
        activeWorkout = Workout(healthKit: healthKit, type: workoutType)
    }
    
    func stopActiveWorkout() {
        guard let activeWorkout = activeWorkout else {
            logger.info("There is not running workout")
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
