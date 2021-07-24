//
//  WorkoutService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import HealthKit
import Combine
import CoreLocation

protocol IWorkoutService {
    func startWorkout(workoutType: WorkoutType)
    func stopActiveWorkout()
    func pauseActiveWorkout()
    func resumeActiveWorkout()
    func getActiveWorkoutElapsedTime() -> TimeInterval?
    func getActiveWorkoutDataPublisher() -> WorkoutDataChangePublishers?
    func getWorkoutStatePublisher() -> AnyPublisher<WorkoutState, Never>
}

enum WorkoutState {
    case notPresent, running, paused, finished
}

class WorkoutService: IWorkoutService {
    private let healthKitService: IHealthKitService
    private let locationManager: WorkoutLocationFetcher
    
    private var activeWorkout: IWorkout?
    @Published private var workoutState: WorkoutState = .notPresent
    
    init(locationManager: LocationManager, healthKitService: HealthKitService) {
        self.locationManager = locationManager
        self.healthKitService = healthKitService
    }
    
    func startWorkout(workoutType: WorkoutType) {
        if activeWorkout != nil {
            print("Workout already exists")
            return
        }
        
        activeWorkout = Workout(healthKit: healthKitService.healthStore, type: workoutType, locationManager: locationManager)
        workoutState = .running
    }
    
    func getWorkoutStatePublisher() -> AnyPublisher<WorkoutState, Never> {
        return $workoutState.eraseToAnyPublisher()
    }
    
    func stopActiveWorkout() {
        guard let activeWorkout = activeWorkout else {
            print("There is not running workout")
            return
        }
        
        activeWorkout.stop()
        workoutState = .finished
        
        self.activeWorkout = nil
        workoutState = .notPresent
    }
    
    func pauseActiveWorkout() {
        activeWorkout?.pause()
        workoutState = .paused
    }
    
    func resumeActiveWorkout() {
        activeWorkout?.resume()
        workoutState = .running
    }
    
    func getActiveWorkoutElapsedTime() -> TimeInterval? {
        guard let activeWorkout = activeWorkout else {
            print("There is not active workout while fetching elapsed time")
            return nil
        }
        
        return activeWorkout.getElapsedTime()
    }
    
    func getActiveWorkoutDataPublisher() -> WorkoutDataChangePublishers? {
        guard let activeWorkout = activeWorkout else {
            print("There is not active workout while getting data publisher")
            return nil
        }
        
        return activeWorkout.dataPublishers
    }
}
