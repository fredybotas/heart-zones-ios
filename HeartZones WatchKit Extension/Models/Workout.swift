//
//  Workout.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import HealthKit
import Combine

struct DistanceData {
    let distance: Measurement<UnitLength>
    let currentSpeed: Measurement<UnitSpeed>
    let averageSpeed: Measurement<UnitSpeed>
    
    init?(statistics: HKStatistics, elapsedTime: TimeInterval) {
        guard let lastLength = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.meter()) else { return nil }
        guard let lastDuration = statistics.mostRecentQuantityDateInterval()?.duration else { return nil } // seconds
        
        guard let totalLength = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) else { return nil }

        distance = Measurement.init(value: totalLength, unit: UnitLength.meters)
        currentSpeed = Measurement.init(value: lastLength / lastDuration, unit: UnitSpeed.metersPerSecond)
        averageSpeed = Measurement.init(value: totalLength / elapsedTime, unit: UnitSpeed.metersPerSecond)
    }
}

struct WorkoutDataChangePublishers {
    let bpmPublisher = PassthroughSubject<Int, Never>()
    let distancePublisher = PassthroughSubject<DistanceData, Never>()
    let energyPublisher = PassthroughSubject<Measurement<UnitEnergy>, Never>()
}

class Workout: NSObject, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    private let workoutType: WorkoutType
    private let healthKit: HKHealthStore
    
    private var activeWorkoutSession: HKWorkoutSession?
    private let dataPublishers = WorkoutDataChangePublishers()

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
    
    private func finalizePublishers() {
        dataPublishers.bpmPublisher.send(completion: .finished)
        dataPublishers.distancePublisher.send(completion: .finished)
        dataPublishers.energyPublisher.send(completion: .finished)
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
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { return }
            
            if quantityType.isEqual(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)) {
                guard let data = DistanceData(statistics: statistics, elapsedTime: workoutBuilder.elapsedTime) else { return }
                self.dataPublishers.distancePublisher.send(data)
            }
            if quantityType.isEqual(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)) {
                guard let beats = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.hertz()) else { return }
                self.dataPublishers.bpmPublisher.send(Int(beats * 60))
            }
            if quantityType.isEqual(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)) {
                guard let energy = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) else { return }
                self.dataPublishers.energyPublisher.send(Measurement(value: energy, unit: UnitEnergy.kilocalories))
            }
        }
    }
    
    func getDataPublishers() -> WorkoutDataChangePublishers {
        return dataPublishers
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("BB")
    }
}
