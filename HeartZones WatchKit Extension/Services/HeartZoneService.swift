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

class HeartZoneService: IHeartZoneService {
    private let workoutService: IWorkoutService
    private let beepingService: IBeepingService
    //TODO: Set correct age
    private let age: Int = 25
    
    private var workoutStateSubscriber: AnyCancellable?
    private var bpmSubscriber: AnyCancellable?
    
    private var currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)
    
    let activeHeartZoneSetting: HeartZonesSetting
    
    init (workoutService: IWorkoutService, beepingService: IBeepingService) {
        self.workoutService = workoutService
        self.beepingService = beepingService

        // TODO: Add logic to evaluate correct heart zone. Now we are using default zones only.
        self.activeHeartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting(age: age)
        
        self.workoutStateSubscriber = self.workoutService
            .getWorkoutStatePublisher()
            .sink { [weak self] val in
                self?.handleStateChange(state: val)
            }
    }

    private func handleStateChange(state: WorkoutState) {
        switch state {
            case .notPresent:
                self.currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)
            case .running:
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
        let (movement, newZone) = activeHeartZoneSetting.evaluateBpmChange(currentZone: currentHeartZonePublisher.value, bpm: bpm)
        if movement != .stay {
            beepingService.handleDeviceBeep(heartZoneMovement: movement, fromTargetZone: self.currentHeartZonePublisher.value?.target ?? false, enteredTargetZone: newZone?.target ?? false)
            self.currentHeartZonePublisher.send(newZone)
        }
    }
    
    func getHeartZonePublisher() -> AnyPublisher<HeartZone, Never> {
        return currentHeartZonePublisher
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
}
