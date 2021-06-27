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
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "workout")
    
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
        builder?.beginCollection(withStart: Date()) { [weak self] (success, error) in
            guard let error = error else {
                self?.logger.info("Collection of workout data started with success: \(success), error: nil")
                return
            }
            self?.logger.error("Collection of workout data started with success: \(success), error: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        activeWorkoutSession?.pause()
    }
    
    func resume() {
        activeWorkoutSession?.resume()
    }
    
    func stop() {
        activeWorkoutSession?.stopActivity(with: Date())
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
