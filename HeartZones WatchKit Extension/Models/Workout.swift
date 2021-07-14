//
//  Workout.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import HealthKit
import Combine
import CoreLocation

struct DistanceData {
    let distance: Measurement<UnitLength>
    let currentSpeed: Measurement<UnitSpeed>
    let averageSpeed: Measurement<UnitSpeed>
}

struct WorkoutDataChangePublishers {
    let bpmPublisher = PassthroughSubject<Int, Never>()
    let distancePublisher = PassthroughSubject<DistanceData, Never>()
    let energyPublisher = PassthroughSubject<Measurement<UnitEnergy>, Never>()
}

protocol IWorkout {
    var dataPublishers: WorkoutDataChangePublishers { get }
    var workoutType: WorkoutType { get }
    
    func pause()
    func resume()
    func stop()
    func getElapsedTime() -> TimeInterval
}

class Workout: NSObject, IWorkout, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    internal let dataPublishers = WorkoutDataChangePublishers()
    internal let workoutType: WorkoutType
    
    private let locationManager: LocationManager
    private let configuration: HKWorkoutConfiguration
    
    private let healthKit: HKHealthStore
    private var activeWorkoutSession: HKWorkoutSession?
    
    private var locationDataPublisher: AnyCancellable?
    private var routeBuilder: HKWorkoutRouteBuilder?
    
    private var bpm = BpmContainer(size: 2)
    private var distances = DistanceContainer(size: 3)

    init(healthKit: HKHealthStore, type: WorkoutType, locationManager: LocationManager) {
        self.healthKit = healthKit
        self.workoutType = type
        self.locationManager = locationManager
        self.configuration = workoutType.getConfiguration()

        super.init()
        
        activeWorkoutSession = try? HKWorkoutSession(healthStore: healthKit, configuration: configuration)
        let builder = activeWorkoutSession?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthKit, workoutConfiguration: configuration)
        builder?.delegate = self
        activeWorkoutSession?.delegate = self

        activeWorkoutSession?.startActivity(with: Date.init())
        builder?.beginCollection(withStart: Date()) { (success, error) in }
        
        setLocationHarvesting()
    }
    
    func setLocationHarvesting() {
        if configuration.locationType == .outdoor {
            locationManager.startWorkoutLocationUpdates()
            self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthKit, device: nil)
            
            locationDataPublisher = locationManager.getWorkoutLocationUpdatesPublisher().sink { [weak self] location in
                self?.routeBuilder?.insertRouteData([location], completion: {
                    result, error in
                    guard result == true else { return }
                    //TODO: Handle error
                })
            }
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
        finalizePublishers()
        locationDataPublisher = nil
        if configuration.locationType == .outdoor {
            locationManager.stopWorkoutLocationUpdates()
        }
        
        activeWorkoutSession?.stopActivity(with: currentDate)
        activeWorkoutSession?.end()
        activeWorkoutSession?.associatedWorkoutBuilder().endCollection(withEnd: currentDate){ (success, error) in
            guard success else {
                return
            }
            
            if self.shouldSaveWorkout() {
                self.activeWorkoutSession?.associatedWorkoutBuilder().finishWorkout { (workout, error) in
                    guard let workout = workout else { return }
                    self.routeBuilder?.finishRoute(with: workout, metadata: nil, completion: { (route, error) in
                        guard success else { return }
                    })
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
    
    private func shouldSaveWorkout() -> Bool {
        let elapsedTime = getElapsedTime()
        if elapsedTime > 60 * 3 {
            // Only save workout if it lasted for at least 3min
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
                handleDistanceData(statistics: statistics)
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
    
    private func handleDistanceData(statistics: HKStatistics) {
        guard let lastLength = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.meter()) else { return }
        guard let lastDuration = statistics.mostRecentQuantityDateInterval()?.duration else { return } // seconds
        guard let totalLength = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) else { return }
        
        distances.insert(distance: lastLength, timeInterval: lastDuration)
        guard let currentSpeed = distances.getAverageSpeed() else { return }

        let data = DistanceData(distance: Measurement.init(value: totalLength, unit: UnitLength.meters), currentSpeed: currentSpeed, averageSpeed: Measurement.init(value: totalLength / getElapsedTime(), unit: UnitSpeed.metersPerSecond))
        self.dataPublishers.distancePublisher.send(data)
    }
    
    internal func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("BB")
    }
}
