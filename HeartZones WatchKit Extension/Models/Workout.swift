//
//  Workout.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import HealthKit
import os

class Workout: NSObject, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    private let workoutType: WorkoutType
    private let healthKit: HKHealthStore
    
    private var activeWorkoutSession: HKWorkoutSession?

    init(healthKit: HKHealthStore, type: WorkoutType) {
        self.healthKit = healthKit
        self.workoutType = type

        super.init()

        let configuration = workoutType.getConfiguration()
        activeWorkoutSession = try? HKWorkoutSession(healthStore: healthKit, configuration: configuration)
        let builder = activeWorkoutSession?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthKit, workoutConfiguration: configuration)
        builder?.delegate = self
        activeWorkoutSession?.delegate = self

        activeWorkoutSession?.startActivity(with: Date.init())
        builder?.beginCollection(withStart: Date()) { (success, error) in

        }
    }
    
    func pause() {
        activeWorkoutSession?.pause()
    }
    
    func resume() {
        activeWorkoutSession?.resume()
    }
    
    func stop() {
        let currentDate = Date()
        activeWorkoutSession?.stopActivity(with: currentDate)
        activeWorkoutSession?.end()
        activeWorkoutSession?.associatedWorkoutBuilder().endCollection(withEnd: currentDate){ [weak self] (success, error) in
            guard success else {
                return
            }
            self?.activeWorkoutSession?.associatedWorkoutBuilder().finishWorkout { (workout, error) in
                guard workout != nil else {
                   return
                }
            }
        }
    }
    
    func getElapsedTime() -> TimeInterval {
        guard let activeWorkoutSession = activeWorkoutSession else {
            print("Workout session is not running")
            return 0.0
        }
        return activeWorkoutSession.associatedWorkoutBuilder().elapsedTime
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("State changed")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("State changed to: " + String(toState.rawValue))
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        print("AA")
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                        return // Nothing to do.
                    }
                    
                    // Calculate statistics for the type.
            let statistics = workoutBuilder.statistics(for: quantityType)
            //statistics!.mostRecentQuantity()
            
            print(statistics!.quantityType)
            //print(statistics!.mostRecentQuantity()?.doubleValue(for: <#T##HKUnit#>))
            print(statistics!.sumQuantity())
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("BB")
    }
}
