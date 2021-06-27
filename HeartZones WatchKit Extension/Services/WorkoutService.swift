//
//  WorkoutService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import HealthKit

class WorkoutService: NSObject, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate{

    let healthKit: HKHealthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    
    func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        workoutSession = try? HKWorkoutSession(healthStore: healthKit, configuration: configuration)
        let builder = workoutSession?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthKit, workoutConfiguration: configuration)
        builder?.delegate = self
        workoutSession?.delegate = self

        workoutSession?.startActivity(with: Date.init())
        builder?.beginCollection(withStart: Date()) { (success, error) in
            print(error)
        }
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
            print(statistics!.mostRecentQuantity()?.doubleValue(for: <#T##HKUnit#>))
            print(statistics!.sumQuantity())
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("BB")
    }
}
