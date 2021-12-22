//
//  WorkoutService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Combine
import CoreLocation
import Foundation
import HealthKit

protocol IWorkoutService {
    func startWorkout(workoutType: WorkoutType)
    func stopActiveWorkout()
    func saveActiveWorkout()
    func discardActiveWorkout()
    func pauseActiveWorkout()
    func resumeActiveWorkout()
    func getActiveWorkoutElapsedTime() -> TimeInterval?
    func getActiveWorkoutDataPublisher() -> WorkoutDataChangePublishers?
    func getActiveWorkoutSummaryPublisher() -> AnyPublisher<WorkoutSummaryData?, Never>?
    func getWorkoutStatePublisher() -> AnyPublisher<WorkoutState, Never>
}

enum WorkoutState {
    case notPresent, running, paused, finished
}

class WorkoutService: IWorkoutService {
    private let healthKitService: IHealthKitService
    private let locationManager: WorkoutLocationFetcher
    private let settingsService: ISettingsService

    private var activeWorkout: IWorkout?
    @Published private var workoutState: WorkoutState = .notPresent

    init(
        locationManager: LocationManager, healthKitService: HealthKitService,
        settingsService: ISettingsService
    ) {
        self.locationManager = locationManager
        self.healthKitService = healthKitService
        self.settingsService = settingsService
    }

    func setRecoveredWorkout(session: HKWorkoutSession) {
        activeWorkout = Workout(healthKit: healthKitService.healthStore,
                                session: session, locationManager: locationManager,
                                settingsService: settingsService)
        activeWorkout?.startWorkout()
        workoutState = activeWorkout!.workoutState
    }

    func startWorkout(workoutType: WorkoutType) {
        if activeWorkout != nil {
            print("Workout already exists")
            return
        }

        activeWorkout = Workout(
            healthKit: healthKitService.healthStore, type: workoutType, locationManager: locationManager,
            settingsService: settingsService
        )
        activeWorkout?.startWorkout()
        workoutState = activeWorkout!.workoutState
    }

    func getWorkoutStatePublisher() -> AnyPublisher<WorkoutState, Never> {
        return $workoutState.eraseToAnyPublisher()
    }

    func stopActiveWorkout() {
        guard let activeWorkout = activeWorkout else {
            print("There is not running workout")
            return
        }

        activeWorkout.stop()
        workoutState = .finished
    }

    func saveActiveWorkout() {
        try? activeWorkout?.saveWorkout()
        activeWorkout = nil
        workoutState = .notPresent
    }

    func discardActiveWorkout() {
        try? activeWorkout?.discardWorkout()
        activeWorkout = nil
        workoutState = .notPresent
    }

    func pauseActiveWorkout() {
        activeWorkout?.pause()
        workoutState = .paused
    }

    func resumeActiveWorkout() {
        activeWorkout?.resume()
        workoutState = .running
    }

    func getActiveWorkoutElapsedTime() -> TimeInterval? {
        guard let activeWorkout = activeWorkout else {
            print("There is not active workout while fetching elapsed time")
            return nil
        }

        return activeWorkout.getElapsedTime()
    }

    func getActiveWorkoutDataPublisher() -> WorkoutDataChangePublishers? {
        guard let activeWorkout = activeWorkout else {
            print("There is not active workout while getting data publisher")
            return nil
        }

        return activeWorkout.dataPublishers
    }

    func getActiveWorkoutSummaryPublisher() -> AnyPublisher<WorkoutSummaryData?, Never>? {
        guard let activeWorkout = activeWorkout else {
            print("There is not active workout while getting summary publisher")
            return nil
        }
        return activeWorkout.getWorkoutSummaryPublisher()
    }
}
