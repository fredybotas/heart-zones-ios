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

struct NotAllowedOperationError: Error {}

struct DistanceData {
    let distance: Measurement<UnitLength>
    let currentSpeed: Measurement<UnitSpeed>
    let averageSpeed: Measurement<UnitSpeed>
}

struct WorkoutSummaryData {
    let workoutType: WorkoutType
    let elapsedTime: TimeInterval
    let avgBpm: Int?
    let bpmColor: HeartZone.Color?
    let timeInTargetZonePercentage: Int
    let timeInTargetColor: HeartZone.Color?
    let distance: Measurement<UnitLength>?
    let averagePace: Measurement<UnitSpeed>?
    let elevationMin: Measurement<UnitLength>?
    let elevationMax: Measurement<UnitLength>?
    let elevationGain: Measurement<UnitLength>?
    let activeEnergy: Measurement<UnitEnergy>?
}

struct WorkoutDataChangePublishers {
    let bpmPublisher = PassthroughSubject<Int, Never>()
    let distancePublisher = PassthroughSubject<DistanceData, Never>()
    let energyPublisher = PassthroughSubject<Measurement<UnitEnergy>, Never>()
    let elevationPublisher = PassthroughSubject<Measurement<UnitLength>, Never>()
}

protocol IWorkout {
    var dataPublishers: WorkoutDataChangePublishers { get }
    var workoutType: WorkoutType { get }
    
    func getWorkoutSummaryPublisher() -> AnyPublisher<WorkoutSummaryData?, Never>
    func pause()
    func resume()
    func stop()
    func saveWorkout() throws
    func discardWorkout() throws
    func getElapsedTime() -> TimeInterval
}

class Workout: NSObject, IWorkout, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    enum State {
        case notInitialized, active, stopped
    }

    internal let dataPublishers = WorkoutDataChangePublishers()
    internal let workoutType: WorkoutType
    
    private let workoutSummaryPublisher: CurrentValueSubject<WorkoutSummaryData?, Never> = CurrentValueSubject(nil)
    private let locationManager: WorkoutLocationFetcher
    private let configuration: HKWorkoutConfiguration
    private let settingsService: ISettingsService
    
    private let healthKit: HKHealthStore
    private var activeWorkoutSession: HKWorkoutSession?
    
    private var locationDataPublisher: AnyCancellable?
    private var routeBuilder: HKWorkoutRouteBuilder?
    
    private var bpm: BpmContainer
    private var distances = DistanceContainer(size: 3)
    private var elevationContainer = ElevationContainer()
    
    private var state: State = .notInitialized
    
    init(healthKit: HKHealthStore, type: WorkoutType, locationManager: WorkoutLocationFetcher, settingsService: ISettingsService) {
        self.healthKit = healthKit
        self.workoutType = type
        self.locationManager = locationManager
        self.configuration = workoutType.getConfiguration()
        self.settingsService = settingsService
        self.bpm = BpmContainer(size: 1, targetHeartZone: settingsService.selectedHeartZoneSetting.zones[settingsService.targetZoneId], maxBpm: settingsService.maximumBpm)
        
        super.init()
        
        self.initializeWorkout()
    }
    
    private func initializeWorkout() {
        activeWorkoutSession = try? HKWorkoutSession(healthStore: healthKit, configuration: configuration)
        let builder = activeWorkoutSession?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthKit, workoutConfiguration: configuration)
        builder?.delegate = self
        activeWorkoutSession?.delegate = self

        activeWorkoutSession?.startActivity(with: Date.init())
        builder?.beginCollection(withStart: Date()) { (success, error) in }
        
        setLocationHarvesting()
        
        self.state = .active
    }
    
    private func setLocationHarvesting() {
        if configuration.locationType == .outdoor {
            locationManager.startWorkoutLocationUpdates()
            self.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthKit, device: nil)
            locationDataPublisher = locationManager.getWorkoutLocationUpdatesPublisher().sink { [weak self] location in
                self?.elevationContainer.insertLocation(loc: location)
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
        finalizeLivePublishers()
        
        if configuration.locationType == .outdoor {
            locationDataPublisher = nil
            locationManager.stopWorkoutLocationUpdates()
        }
        
        self.stopWorkoutInternal()
    }
    
    func saveWorkout() throws {
        if state != .stopped {
            throw NotAllowedOperationError()
        }
        workoutSummaryPublisher.send(completion: .finished)
        self.activeWorkoutSession?.associatedWorkoutBuilder().finishWorkout { (workout, error) in
            guard let workout = workout else { return }
            self.routeBuilder?.finishRoute(with: workout, metadata: nil, completion: { (route, error) in })
        }
    }
    
    func discardWorkout() throws {
        if state != .stopped {
            throw NotAllowedOperationError()
        }
        workoutSummaryPublisher.send(completion: .finished)
        self.activeWorkoutSession?.associatedWorkoutBuilder().discardWorkout()
    }
    
    private func stopWorkoutInternal() {
        let currentDate = Date()
        activeWorkoutSession?.stopActivity(with: currentDate)
        activeWorkoutSession?.end()
        activeWorkoutSession?.associatedWorkoutBuilder().endCollection(withEnd: currentDate){ [weak self] (success, error) in
            self?.state = .stopped
            self?.prepareWorkoutSummary()
            guard success else {
                return
            }
        }
    }
    
    private func prepareWorkoutSummary() {
        if state != .stopped {
            workoutSummaryPublisher.send(nil)
            return
        }
        let avgBpm = getAverageBpm()
        let summaryData = WorkoutSummaryData(workoutType: workoutType, elapsedTime: getElapsedTime(), avgBpm: avgBpm, bpmColor: getBpmColor(avgBpm: avgBpm), timeInTargetZonePercentage: bpm.timeInTargetZonePercentage(), timeInTargetColor: getTimeInTargetColor(), distance: getRunningDistance(), averagePace: getAverageSpeed(), elevationMin: elevationContainer.getMinElevation(), elevationMax: elevationContainer.getMaxElevation(), elevationGain: elevationContainer.getElevationGain(), activeEnergy: getActiveEnergy())
        workoutSummaryPublisher.send(summaryData)
    }
    
    private func getBpmColor(avgBpm: Int?) -> HeartZone.Color? {
        guard let avgBpm = avgBpm else { return nil }
        let bpmPercentage = Double(avgBpm) / Double(settingsService.maximumBpm)
        let positiveZones = settingsService.selectedHeartZoneSetting.zones.filter { $0.bpmRangePercentage.contains(Int(bpmPercentage * 100)) }
        return positiveZones.first?.color
    }
    
    private func getTimeInTargetColor() -> HeartZone.Color? {
        return settingsService.selectedHeartZoneSetting.zones[settingsService.targetZoneId].color
    }
    
    // TODO: Refactor getters
    private func getAverageBpm() -> Int? {
        let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        guard let type = type else { return nil }
        let hertzs = activeWorkoutSession?.associatedWorkoutBuilder().statistics(for: type)?.averageQuantity()?.doubleValue(for: HKUnit.hertz())
        guard let hertzs = hertzs else { return nil }
        return Int(hertzs * 60)
    }
    
    private func getRunningDistance() -> Measurement<UnitLength>? {
        let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        guard let type = type else { return nil }
        let distance = activeWorkoutSession?.associatedWorkoutBuilder().statistics(for: type)?.sumQuantity()?.doubleValue(for: HKUnit.meter())
        guard let distance = distance else { return nil }
        return Measurement.init(value: distance, unit: UnitLength.meters)
    }
    
    private func getAverageSpeed() -> Measurement<UnitSpeed>? {
        let distance = getRunningDistance()
        let time = getElapsedTime()
        guard let distance = distance else { return nil }
        let speedMetersPerSec = distance.converted(to: UnitLength.meters).value / time
        return Measurement.init(value: speedMetersPerSec, unit: UnitSpeed.metersPerSecond)
    }
    
    private func getActiveEnergy() -> Measurement<UnitEnergy>? {
        let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        guard let type = type else { return nil }
        let energy = activeWorkoutSession?.associatedWorkoutBuilder().statistics(for: type)?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
        guard let energy = energy else { return nil }
        return Measurement.init(value: energy, unit: UnitEnergy.kilocalories)
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
    
    private func finalizeLivePublishers() {
        dataPublishers.bpmPublisher.send(completion: .finished)
        dataPublishers.distancePublisher.send(completion: .finished)
        dataPublishers.energyPublisher.send(completion: .finished)
        dataPublishers.elevationPublisher.send(completion: .finished)
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
                guard let energy = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) else { continue }
                self.dataPublishers.energyPublisher.send(Measurement(value: energy, unit: UnitEnergy.kilocalories))
            }
        }
        
        if let elevationGain = elevationContainer.getElevationGain() {
            self.dataPublishers.elevationPublisher.send(elevationGain)
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
    
    func getWorkoutSummaryPublisher() -> AnyPublisher<WorkoutSummaryData?, Never> {
        return workoutSummaryPublisher.eraseToAnyPublisher()
    }

    
    internal func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
