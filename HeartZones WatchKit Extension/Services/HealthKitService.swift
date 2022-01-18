//
//  HealthKitService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/07/2021.
//

import Combine
import Foundation
import HealthKit

protocol IHealthKitService {
    var healthStore: HKHealthStore { get }
    var age: Int? { get }

    func getBpmData(startDate: NSDate, endDate: NSDate) -> Future<[BpmEntry], Never>
    func getBpmDataForWorkout(workout: HKWorkout) -> Future<[BpmEntry], Never>
}

struct WorkoutNotSpecifiedError: Error {}

class HealthKitService: IHealthKitService, Authorizable {
    let healthStore = HKHealthStore()

    lazy var age: Int? = {
        var date: DateComponents?
        do {
            date = try healthStore.dateOfBirthComponents()
        } catch {}
        guard let dateComponents = date else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents(
            [.year], from: dateComponents,
            to: calendar.dateComponents([.year, .month, .day], from: Date())
        )
        guard let age = ageComponents.year else { return nil }
        NSLog("Age received from healtkit: %d", age)
        return age
    }()

    let readMetrics = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKCharacteristicType.characteristicType(
            forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!
    ]

    let writeMetrics = [
        HKSeriesType.workoutRoute(),
        HKQuantityType.workoutType()
    ]

    func requestAuthorization() -> Future<Bool, Never> {
        let writeMetrics = self.writeMetrics
        let readMetrics = self.readMetrics
        return Future<Bool, Never>({ [weak self] promise in
            guard HKHealthStore.isHealthDataAvailable() else {
                promise(.success(false))
                return
            }
            self?.healthStore.requestAuthorization(
                toShare: Set<HKSampleType>(writeMetrics), read: Set<HKObjectType>(readMetrics)
            ) { authorized, error in
                guard authorized else {
                    guard error != nil else {
                        promise(.success(false))
                        return
                    }
                    promise(.success(false))
                    return
                }
                promise(.success(true))
            }
        })
    }

    func recoverWorkout() -> Future<HKWorkoutSession, Error> {
        let future = Future<HKWorkoutSession, Error>({ [weak self] promise in
            self?.healthStore.recoverActiveWorkoutSession(completion: { workout, error in
                if let workout = workout, workout.state != .ended {
                    promise(.success(workout))
                } else if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.failure(WorkoutNotSpecifiedError()))
                }
            })
        })
        return future
    }

    func getBpmData(startDate: NSDate, endDate: NSDate) -> Future<[BpmEntry], Never> {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate as Date, end: endDate as Date?, options: []
        )
        return getBpmData(for: predicate)
    }

    func getBpmDataForWorkout(workout: HKWorkout) -> Future<[BpmEntry], Never> {
        let predicate = HKQuery.predicateForObjects(from: workout)
        return getBpmData(for: predicate)
    }

    private func getBpmData(for predicate: NSPredicate) -> Future<[BpmEntry], Never> {
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        let future = Future<[BpmEntry], Never>({ [weak self] promise in
            let heartRateQuery = HKSampleQuery(
                sampleType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: sortDescriptors,
                resultsHandler: { _, results, error in
                    guard error == nil else {
                        promise(.success([]))
                        return
                    }
                    guard let results = results else {
                        promise(.success([]))
                        return
                    }
                    promise(
                        .success(
                            results
                                .compactMap { $0 as? HKQuantitySample }
                                .map {
                                    BpmEntry(
                                        value: Int($0.quantity.doubleValue(for: HKUnit(from: "count/min"))),
                                        timestamp: $0.endDate.timeIntervalSince1970
                                    )
                                }))
                }
            )
            self?.healthStore.execute(heartRateQuery)
        })
        return future
    }
}
