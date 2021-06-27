//
//  HeartZonesApp.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 23/06/2021.
//

import SwiftUI
import HealthKit

@main
struct HeartZonesApp: App {
    init() {
        HeartZonesApp.authorizeHealthKitAccess(toRead: [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ], toWrite: [
            HKQuantityType.workoutType()
        ], completion: { (result, code) in
            print(result)
        })
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

    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                WorkoutSelectionView(workoutSelectionViewModel: WorkoutSelectionViewModel())
            }
        }
    }
}
