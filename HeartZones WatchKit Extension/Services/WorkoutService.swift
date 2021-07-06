//
//  WorkoutService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import HealthKit
import Combine
import os

protocol IWorkoutService {
    func startWorkout(workoutType: WorkoutType)
    func stopActiveWorkout()
    func pauseActiveWorkout()
    func resumeActiveWorkout()
    func getActiveWorkoutElapsedTime() -> TimeInterval?
    func getActiveWorkoutDataPublisher() -> WorkoutDataChangePublishers?
}

class WorkoutService: IWorkoutService {
    private let healthKit: HKHealthStore = HKHealthStore()
    private var activeWorkout: IWorkout?
    
    func startWorkout(workoutType: WorkoutType) {
        if activeWorkout != nil {
            print("Workout already exists")
            return
        }
        
        activeWorkout = Workout(healthKit: healthKit, type: workoutType)
    }
    
    func stopActiveWorkout() {
        guard let activeWorkout = activeWorkout else {
            print("There is not running workout")
            return
        }
        activeWorkout.stop()
        self.activeWorkout = nil
    }
    
    func pauseActiveWorkout() {
        activeWorkout?.pause()
    }
    
    func resumeActiveWorkout() {
        activeWorkout?.resume()
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
        
        return activeWorkout.getDataPublishers()
    }
    
    static func authorizeHealthKitAccess(toRead readable: Set<HKObjectType>?, toWrite writable: Set<HKSampleType>?, completion: @escaping (Bool, HKError.Code?) -> Void)
    {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, .errorHealthDataUnavailable)
            return
        }
        HKHealthStore().requestAuthorization(toShare: writable, read: readable) { (authorized, error) in
            guard authorized else {
                guard error != nil else {
                    completion(false, .noError)
                    return
                }
                print("HealthKit Error:\n\(error!)") // Comment this out for release
                completion(false, .errorAuthorizationDenied)
                return
            }
            completion(true, nil)
        }
    }

}
