//
//  HeartZoneService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Combine
import Foundation
import SwiftUI

protocol IHeartZoneService {
    func getHeartZonePublisher() -> AnyPublisher<HeartZone, Never>
}

class HeartZoneService: IHeartZoneService, ZoneStateManager {
    private let workoutService: IWorkoutService
    private let beepingService: IBeepingService
    private let healthKitService: IHealthKitService
    private var settingsService: ISettingsService

    private var workoutStateSubscriber: AnyCancellable?
    private var bpmSubscriber: AnyCancellable?

    private var currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)

    private(set) var activeHeartZoneSetting: HeartZonesSetting?

    private var heartZoneState: BaseHeartZoneState?

    init(
        workoutService: IWorkoutService, beepingService: IBeepingService,
        healthKitService: IHealthKitService, settingsService: ISettingsService
    ) {
        self.workoutService = workoutService
        self.beepingService = beepingService
        self.healthKitService = healthKitService
        self.settingsService = settingsService

        workoutStateSubscriber = self.workoutService
            .getWorkoutStatePublisher()
            .sink { [weak self] val in
                self?.handleStateChange(state: val)
            }
    }

    private func resolveHeartZoneSetting() {
        // Make sure that it is called after permissions were requested
        activeHeartZoneSetting = settingsService.selectedHeartZoneSetting
    }

    private func handleStateChange(state: WorkoutState) {
        switch state {
        case .notPresent:
            heartZoneState = HeartZoneNotAvailableState(
                stateManager: self, settingsService: settingsService
            )
            currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)
        case .paused:
            // swiftlint:disable:next no_fallthrough_only
            fallthrough
        case .running:
            heartZoneState = HeartZoneNotAvailableState(
                stateManager: self, settingsService: settingsService
            )
            resolveHeartZoneSetting()
            connectBpmSubscriberIfNeeded()
        case .finished:
            currentHeartZonePublisher.send(completion: .finished)
            beepingService.stopAnyBeeping()
        }
    }

    private func connectBpmSubscriberIfNeeded() {
        if bpmSubscriber != nil {
            return
        }

        bpmSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .bpmPublisher
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.bpmSubscriber = nil
                },
                receiveValue: { [weak self] bpm in
                    self?.handleBpmChange(bpm: bpm)
                }
            )
    }

    private func handleBpmChange(bpm: Int) {
        heartZoneState?.bpmChanged(bpm: bpm)
    }

    func setState(state: BaseHeartZoneState) {
        heartZoneState = state

        beepingService.handleDeviceBeep(
            heartZoneMovement: state.movement,
            fromTargetZone: currentHeartZonePublisher.value?.target ?? false,
            enteredTargetZone: state.zone?.target ?? false
        )
        currentHeartZonePublisher.send(state.zone)
    }

    func getHeartZonePublisher() -> AnyPublisher<HeartZone, Never> {
        return
            currentHeartZonePublisher
                .compactMap { $0 }
                .eraseToAnyPublisher()
    }
}
