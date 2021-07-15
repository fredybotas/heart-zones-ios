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
    private let healthKit = HKHealthStore()
    private let locationManager: WorkoutLocationFetcher
    
    private var activeWorkout: IWorkout?
    @Published private var workoutState: WorkoutState = .notPresent
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func startWorkout(workoutType: WorkoutType) {
        if activeWorkout != nil {
            print("Workout already exists")
            return
        }
        
        activeWorkout = Workout(healthKit: healthKit, type: workoutType, locationManager: locationManager)
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
