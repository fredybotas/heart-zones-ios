//
//  Workout.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Combine
import CoreLocation
import Foundation
import HealthKit

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
    let timeInTargetZonePercentage: Double
    let timeInTargetColor: HeartZone.Color?
    let distance: Measurement<UnitLength>?
    let averagePace: Measurement<UnitSpeed>?
    let elevationMin: Measurement<UnitLength>?
    let elevationMax: Measurement<UnitLength>?
    let activeEnergy: Measurement<UnitEnergy>?
}

struct WorkoutDataChangePublishers {
    let bpmPublisher = PassthroughSubject<Int, Never>()
    let distancePublisher = PassthroughSubject<DistanceData, Never>()
    let energyPublisher = PassthroughSubject<Measurement<UnitEnergy>, Never>()
    let currentElevationPublisher = PassthroughSubject<Measurement<UnitLength>, Never>()
}

protocol IWorkout {
    var dataPublishers: WorkoutDataChangePublishers { get }
    var workoutType: WorkoutType { get }
    var workoutState: WorkoutState { get }

    func getWorkoutSummaryPublisher() -> AnyPublisher<WorkoutSummaryData?, Never>
    func startWorkout()
    func pause()
    func resume()
    func stop()
    func saveWorkout() throws
    func discardWorkout() throws
    func getElapsedTime() -> TimeInterval
    func getStartTime() -> Date?
    func getWorkoutZoneStatistics() -> ZoneStatistics
}

// swiftlint:disable:next type_body_length
class Workout: NSObject, IWorkout, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    enum State {
        case notInitialized, active, stopped
    }

    internal let dataPublishers = WorkoutDataChangePublishers()
    internal let workoutType: WorkoutType
    internal var workoutState: WorkoutState {
        guard let hkState = activeWorkoutSession?.state else {
            return .notPresent
        }
        switch hkState {
        case .notStarted:
            return .running
        case .running:
            return .running
        case .ended:
            return .finished
        case .paused:
            return .paused
        case .prepared:
            return .running
        case .stopped:
            return .finished
        @unknown default:
            return .running
        }
    }

    private let workoutSummaryPublisher: CurrentValueSubject<WorkoutSummaryData?, Never> =
        CurrentValueSubject(nil)
    private let locationManager: WorkoutLocationFetcher
    private let configuration: HKWorkoutConfiguration
    private let settingsService: ISettingsService
    private let zoneStatisticsCalculator: IZoneStaticticsCalculator

    private let healthKitService: IHealthKitService
    private let workoutActiveTimeProcessor: WorkoutActiveTimeProcessor

    private var activeWorkoutSession: HKWorkoutSession?

    private var locationDataPublisher: AnyCancellable?
    private var routeBuilder: HKWorkoutRouteBuilder?

    private var distances = DistanceContainer(size: 3)
    private var elevationContainer = ElevationContainer()

    private var state: State = .notInitialized

    convenience init(
        healthKitService: IHealthKitService, session: HKWorkoutSession, locationManager: WorkoutLocationFetcher,
        settingsService: ISettingsService, zoneStatisticsCalculator: IZoneStaticticsCalculator
    ) {
        self.init(healthKitService: healthKitService,
                  type: WorkoutType.configurationToType(configuration: session.workoutConfiguration),
                  locationManager: locationManager,
                  settingsService: settingsService, zoneStatisticsCalculator: zoneStatisticsCalculator)
        activeWorkoutSession = session
    }

    init(
        healthKitService: IHealthKitService, type: WorkoutType, locationManager: WorkoutLocationFetcher,
        settingsService: ISettingsService, zoneStatisticsCalculator: IZoneStaticticsCalculator
    ) {
        self.healthKitService = healthKitService
        workoutType = type
        self.locationManager = locationManager
        configuration = workoutType.getConfiguration()
        self.settingsService = settingsService
        self.zoneStatisticsCalculator = zoneStatisticsCalculator
        workoutActiveTimeProcessor = WorkoutActiveTimeProcessor()
        super.init()
    }

    func startWorkout() {
        var workoutExisted = true
        if activeWorkoutSession == nil {
            activeWorkoutSession = try? HKWorkoutSession(
                healthStore: healthKitService.healthStore, configuration: configuration
            )
            workoutExisted = false
        }
        let builder = activeWorkoutSession?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthKitService.healthStore, workoutConfiguration: configuration
        )
        builder?.delegate = self
        activeWorkoutSession?.delegate = self
        if !workoutExisted {
            activeWorkoutSession?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { _, _ in }
        }

        setLocationHarvesting()

        state = .active
    }

    private func getWorkoutEvents() -> [HKWorkoutEvent] {
        guard let events = activeWorkoutSession?.associatedWorkoutBuilder().workoutEvents else {
            return []
        }
        return events
    }

    private func setLocationHarvesting() {
        if configuration.locationType == .outdoor {
            locationManager.startWorkoutLocationUpdates()
            routeBuilder = HKWorkoutRouteBuilder(healthStore: healthKitService.healthStore, device: nil)
            locationDataPublisher = locationManager.getWorkoutLocationUpdatesPublisher().sink { [weak self] location in
                self?.handleLocationData(location: location)
            }
        }
    }

    private func handleLocationData(location: CLLocation) {
        elevationContainer.insertLocation(loc: location)
        routeBuilder?.insertRouteData(
            [location],
            completion: { result, _ in
                guard result == true else { return }
                // TODO: Handle error
            }
        )
        dataPublishers
            .currentElevationPublisher
            .send(Measurement(value: location.altitude, unit: UnitLength.meters))
    }

    func pause() {
        activeWorkoutSession?.pause()
        activeWorkoutSession?
            .associatedWorkoutBuilder()
            .addWorkoutEvents([
                HKWorkoutEvent(type: .pause, dateInterval: DateInterval(start: Date(), duration: 0), metadata: [:])
            ]) { _, error in
                if error != nil {
                    print(error!)
                }
            }
    }

    func resume() {
        activeWorkoutSession?.resume()
        activeWorkoutSession?
            .associatedWorkoutBuilder()
            .addWorkoutEvents([
                HKWorkoutEvent(type: .resume, dateInterval: DateInterval(start: Date(), duration: 0), metadata: [:])
            ]) { _, error in
                if error != nil {
                    print(error!)
                }
            }
    }

    func stop() {
        finalizeLivePublishers()

        if configuration.locationType == .outdoor {
            locationDataPublisher = nil
            locationManager.stopWorkoutLocationUpdates()
        }

        stopWorkoutInternal()
    }

    func saveWorkout() throws {
        if state != .stopped {
            throw NotAllowedOperationError()
        }
        workoutSummaryPublisher.send(completion: .finished)
        activeWorkoutSession?.associatedWorkoutBuilder().finishWorkout { workout, _ in
            guard let workout = workout else { return }
            self.routeBuilder?.finishRoute(with: workout, metadata: nil, completion: { _, _ in })
        }
    }

    func discardWorkout() throws {
        if state != .stopped {
            throw NotAllowedOperationError()
        }
        workoutSummaryPublisher.send(completion: .finished)
        activeWorkoutSession?.associatedWorkoutBuilder().discardWorkout()
    }

    private func stopWorkoutInternal() {
        let currentDate = Date()
        activeWorkoutSession?.stopActivity(with: currentDate)
        activeWorkoutSession?.end()
        activeWorkoutSession?.associatedWorkoutBuilder().endCollection(withEnd: currentDate) { [weak self] success, _ in
            self?.state = .stopped
            guard success else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.prepareWorkoutSummary()
            }
        }
    }

    private func prepareWorkoutSummary() {
        if state != .stopped {
            workoutSummaryPublisher.send(nil)
            return
        }
        let avgBpm = getAverageBpm()
        let summaryData = WorkoutSummaryData(
            workoutType: workoutType, elapsedTime: getElapsedTime(), avgBpm: avgBpm,
            bpmColor: getBpmColor(avgBpm: avgBpm),
            timeInTargetZonePercentage: zoneStatisticsCalculator
                .calculatePercentageInTargetZone(segments: getBpmEntries()),
            timeInTargetColor: getTimeInTargetColor(), distance: getRunningDistance(),
            averagePace: getAverageSpeed(), elevationMin: elevationContainer.getMinElevation(),
            elevationMax: elevationContainer.getMaxElevation(),
            activeEnergy: getActiveEnergy()
        )
        workoutSummaryPublisher.send(summaryData)
    }

    func getWorkoutZoneStatistics() -> ZoneStatistics {
        return zoneStatisticsCalculator.calculateStatisticsFor(segments: getBpmEntries())
    }

    private func getBpmEntries() -> [BpmEntrySegment] {
        guard let startTime = activeWorkoutSession?.associatedWorkoutBuilder().startDate else {
            return []
        }
        let endTime = activeWorkoutSession?.associatedWorkoutBuilder().endDate
        let pauseAndResumeEvents = getWorkoutEvents()
            .filter { $0.type == HKWorkoutEventType.pause || $0.type == HKWorkoutEventType.resume }
        let segments = workoutActiveTimeProcessor
            .getActiveTimeSegmentsForWorkout(
                startDate: startTime,
                endDate: endTime,
                workoutEvents: pauseAndResumeEvents.map {
                    WorkoutEvent(type: $0.type == HKWorkoutEventType.pause ? .pauseWorkout : .resumeWorkout,
                                 date: $0.dateInterval.end)
                }
            )
        segments.forEach { $0.fillEntries(healthKitService: healthKitService) }
        return segments
    }

    private func getBpmColor(avgBpm: Int?) -> HeartZone.Color? {
        guard let avgBpm = avgBpm else { return nil }
        let bpmPercentage = Double(avgBpm) / Double(settingsService.maximumBpm)
        let positiveZones = settingsService.selectedHeartZoneSetting.zones.filter {
            $0.bpmRangePercentage.contains(Int(bpmPercentage * 100))
        }
        return positiveZones.first?.color
    }

    private func getTimeInTargetColor() -> HeartZone.Color? {
        return settingsService.selectedHeartZoneSetting.zones[settingsService.targetZoneId].color
    }

    // TODO: Refactor getters
    private func getAverageBpm() -> Int? {
        let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        guard let type = type else { return nil }
        let hertzs = activeWorkoutSession?.associatedWorkoutBuilder().statistics(for: type)?
            .averageQuantity()?.doubleValue(for: HKUnit.hertz())
        guard let hertzs = hertzs else { return nil }
        return Int(hertzs * 60)
    }

    private func getRunningDistance() -> Measurement<UnitLength>? {
        let type = HKObjectType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        guard let type = type else { return nil }
        let distance = activeWorkoutSession?.associatedWorkoutBuilder().statistics(for: type)?
            .sumQuantity()?.doubleValue(for: HKUnit.meter())
        guard let distance = distance else { return nil }
        return Measurement(value: distance, unit: UnitLength.meters)
    }

    private func getAverageSpeed() -> Measurement<UnitSpeed>? {
        let distance = getRunningDistance()
        let time = getElapsedTime()
        guard let distance = distance else { return nil }
        let speedMetersPerSec = distance.converted(to: UnitLength.meters).value / time
        return Measurement(value: speedMetersPerSec, unit: UnitSpeed.metersPerSecond)
    }

    private func getActiveEnergy() -> Measurement<UnitEnergy>? {
        let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        guard let type = type else { return nil }
        let energy = activeWorkoutSession?.associatedWorkoutBuilder().statistics(for: type)?
            .sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
        guard let energy = energy else { return nil }
        return Measurement(value: energy, unit: UnitEnergy.kilocalories)
    }

    func getElapsedTime() -> TimeInterval {
        guard let activeWorkoutSession = activeWorkoutSession else {
            print("Workout session is not running")
            return 0.0
        }
        return activeWorkoutSession.associatedWorkoutBuilder().elapsedTime
    }

    func getStartTime() -> Date? {
        return activeWorkoutSession?.associatedWorkoutBuilder().startDate
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
        dataPublishers.currentElevationPublisher.send(completion: .finished)
    }

    internal func workoutSession(_: HKWorkoutSession, didFailWithError _: Error) {
        print("State changed")
    }

    internal func workoutSession(
        _: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
        from _: HKWorkoutSessionState, date _: Date
    ) {
        print("State changed to: " + String(toState.rawValue))
    }

    internal func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { return }

            if quantityType.isEqual(
                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)) {
                handleDistanceData(statistics: statistics)
            }
            if quantityType.isEqual(
                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)) {
                handleBpmData(statistics: statistics)
            }
            if quantityType.isEqual(
                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)) {
                guard let energy = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) else {
                    continue
                }
                dataPublishers.energyPublisher.send(
                    Measurement(value: energy, unit: UnitEnergy.kilocalories))
            }
        }
    }

    private func handleBpmData(statistics: HKStatistics) {
        guard let beats = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.hertz()) else {
            return
        }
        let bpmToSend = Int(beats * 60)
        dataPublishers.bpmPublisher.send(bpmToSend)
    }

    private func handleDistanceData(statistics: HKStatistics) {
        guard let lastLength = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.meter()) else {
            return
        }
        guard let lastDuration = statistics.mostRecentQuantityDateInterval()?.duration else { return } // seconds
        guard let totalLength = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) else {
            return
        }

        distances.insert(distance: lastLength, timeInterval: lastDuration)
        guard let currentSpeed = distances.getAverageSpeed() else { return }

        let data = DistanceData(
            distance: Measurement(value: totalLength, unit: UnitLength.meters),
            currentSpeed: currentSpeed,
            averageSpeed: Measurement(
                value: totalLength / getElapsedTime(), unit: UnitSpeed.metersPerSecond
            )
        )
        dataPublishers.distancePublisher.send(data)
    }

    func getWorkoutSummaryPublisher() -> AnyPublisher<WorkoutSummaryData?, Never> {
        return workoutSummaryPublisher.eraseToAnyPublisher()
    }

    internal func workoutBuilderDidCollectEvent(_: HKLiveWorkoutBuilder) {}
} // swiftlint:disable:this file_length
