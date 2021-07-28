//
//  HeartZoneService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import SwiftUI
import Combine

protocol IHeartZoneService {
    func getHeartZonePublisher() -> AnyPublisher<HeartZone, Never>
}

class HeartZoneService: IHeartZoneService, ZoneStateManager {
    private let workoutService: IWorkoutService
    private let beepingService: IBeepingService
    private let healthKitService: IHealthKitService
    
    private var workoutStateSubscriber: AnyCancellable?
    private var bpmSubscriber: AnyCancellable?
    
    private var currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)

    // TODO: Add logic to evaluate correct heart zone. Now we are using default zones only.
    private(set) var activeHeartZoneSetting: HeartZonesSetting?
    
    private var heartZoneState: BaseHeartZoneState?
    
    init (workoutService: IWorkoutService, beepingService: IBeepingService, healthKitService: IHealthKitService) {
        self.workoutService = workoutService
        self.beepingService = beepingService
        self.healthKitService = healthKitService
    
        self.workoutStateSubscriber = self.workoutService
            .getWorkoutStatePublisher()
            .sink { [weak self] val in
                self?.handleStateChange(state: val)
            }
    }
    
    private func resolveHeartZoneSetting() {
        // Make sure that it is called after permissions were requested
        self.activeHeartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting(age: self.healthKitService.age)
    }

    private func handleStateChange(state: WorkoutState) {
        switch state {
            case .notPresent:
                self.heartZoneState = HeartZoneNotAvailableState(stateManager: self)
                self.currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)
            case .running:
                self.heartZoneState = HeartZoneNotAvailableState(stateManager: self)
                self.resolveHeartZoneSetting()
                self.connectBpmSubscriberIfNeeded()
            case .finished:
                self.currentHeartZonePublisher.send(completion: .finished)
                self.beepingService.stopAnyBeeping()
            default:
                break
        }
    }
    
    private func connectBpmSubscriberIfNeeded() {
        if bpmSubscriber != nil {
            return
        }
        
        bpmSubscriber = self.workoutService
            .getActiveWorkoutDataPublisher()?
            .bpmPublisher
            .sink(receiveCompletion: { [weak self] _ in
                self?.bpmSubscriber = nil
            }, receiveValue: { [weak self] bpm in
                self?.handleBpmChange(bpm: bpm)
            })
    }
    
    private func handleBpmChange(bpm: Int) {
        self.heartZoneState?.bpmChanged(bpm: bpm)
    }
    
    func setState(state: BaseHeartZoneState) {
        self.heartZoneState = state
        
        self.beepingService.handleDeviceBeep(heartZoneMovement: state.movement, fromTargetZone: self.currentHeartZonePublisher.value?.target ?? false, enteredTargetZone: state.zone?.target ?? false)
        self.currentHeartZonePublisher.send(state.zone)
    }
    
    func getHeartZonePublisher() -> AnyPublisher<HeartZone, Never> {
        return currentHeartZonePublisher
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
}
