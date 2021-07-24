//
//  HealthKitService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/07/2021.
//

import Foundation
import HealthKit

let kDefaultAge = 25

protocol IHealthKitService {
    var healthStore: HKHealthStore { get }
    var age: Int { get }
    
    func authorizeHealthKitAccess(completion: @escaping (Bool, HKError.Code?) -> Void)
}

class HealthKitService: IHealthKitService {
    let healthStore = HKHealthStore()
    
    var age: Int {
        get {
            var date: DateComponents?
            do {
                date = try healthStore.dateOfBirthComponents()
            } catch {}
            guard let dateComponents = date else { return kDefaultAge }
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dateComponents, to: calendar.dateComponents([.year, .month, .day], from: Date()))
            guard let age = ageComponents.year else { return kDefaultAge }
            NSLog("Age received from healtkit: %d", age)
            return age
        }
    }
    
    let readMetrics = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
    ]
    
    let writeMetrics = [
        HKSeriesType.workoutRoute(),
        HKQuantityType.workoutType()
    ]

    func authorizeHealthKitAccess(completion: @escaping (Bool, HKError.Code?) -> Void)
    {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, .errorHealthDataUnavailable)
            return
        }
        healthStore.requestAuthorization(toShare: Set<HKSampleType>(writeMetrics), read: Set<HKObjectType>(readMetrics)) { (authorized, error) in
            guard authorized else {
                guard error != nil else {
                    completion(false, .noError)
                    return
                }
                completion(false, .errorAuthorizationDenied)
                return
            }
            completion(true, nil)
        }
    }
}

