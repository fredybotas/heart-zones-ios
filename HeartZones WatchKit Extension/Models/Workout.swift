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

struct BpmContainer {
    private var array = [Int]()
    private let size: UInt
    
    init(size: UInt) {
        self.size = size
    }
    
    mutating func insert(bpm: Int) {
        array.append(bpm)
        if array.count > size {
            array.remove(at: 0)
        }
    }
    
    func getActualBpm() -> Int? {
        if array.count < size {
            return nil
        }
        return array.reduce(0, { $0 + $1 }) / array.count
    }
}

protocol IWorkout {
    func pause()
    func resume()
    func stop()
    func getElapsedTime() -> TimeInterval
    func getDataPublishers() -> WorkoutDataChangePublishers
}

class Workout: NSObject, IWorkout, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    private let workoutType: WorkoutType
    private let healthKit: HKHealthStore
    
    private var activeWorkoutSession: HKWorkoutSession?
    private let dataPublishers = WorkoutDataChangePublishers()
    
    private var bpm = BpmContainer(size: 3)

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
            guard let self = self else { return }
            guard success else {
                return
            }
            if self.shouldSaveWorkout() {
                self.activeWorkoutSession?.associatedWorkoutBuilder().finishWorkout { (workout, error) in
                    guard workout != nil else {
                       return
                    }
                }
            } else {
                self.activeWorkoutSession?.associatedWorkoutBuilder().discardWorkout()
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
    
    func getDataPublishers() -> WorkoutDataChangePublishers {
        return dataPublishers
    }
    
    private func shouldSaveWorkout() -> Bool {
        let elapsedTime = getElapsedTime()
        if elapsedTime > 60 * 5 {
            // Only save workout if it lasted for 5min
            return true
        }
        return false
    }
    
    private func finalizePublishers() {
        dataPublishers.bpmPublisher.send(completion: .finished)
        dataPublishers.distancePublisher.send(completion: .finished)
        dataPublishers.energyPublisher.send(completion: .finished)
    }
    
    internal func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("State changed")
    }
    
    internal func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("State changed to: " + String(toState.rawValue))
    }
    
    internal func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { return }
            
            if quantityType.isEqual(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)) {
                guard let data = DistanceData(statistics: statistics, elapsedTime: workoutBuilder.elapsedTime) else { return }
                self.dataPublishers.distancePublisher.send(data)
            }
            if quantityType.isEqual(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)) {
                handleBpmData(statistics: statistics)
            }
            if quantityType.isEqual(HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)) {
                guard let energy = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) else { return }
                self.dataPublishers.energyPublisher.send(Measurement(value: energy, unit: UnitEnergy.kilocalories))
            }
        }
    }
    
    private func handleBpmData(statistics: HKStatistics) {
        guard let beats = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.hertz()) else { return }
        bpm.insert(bpm: Int(beats * 60))
        guard let bpmToSend = bpm.getActualBpm() else { return }
        self.dataPublishers.bpmPublisher.send(bpmToSend)
    }
    
    internal func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("BB")
    }
}
