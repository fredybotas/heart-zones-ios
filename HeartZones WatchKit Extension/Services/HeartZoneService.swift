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
    private let deviceBeeper: Beeper
    private let activeHeartZoneSetting: HeartZonesSetting
    //TODO: Set correct age
    private let age: Int = 25
    
    private var workoutStateSubscriber: AnyCancellable?
    private var bpmSubscriber: AnyCancellable?
    
    private var currentHeartZonePublisher = CurrentValueSubject<HeartZone?, Never>(nil)
        
    init (workoutService: IWorkoutService, deviceBeeper: Beeper) {
        self.workoutService = workoutService
        self.deviceBeeper = deviceBeeper
        // TODO: Add logic to evaluate correct heart zone. Now we are using default zones only.
        self.activeHeartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting(age: age)
        
        self.workoutStateSubscriber = self.workoutService
            .getWorkoutStatePublisher()
            .filter({ $0 == .running})
            .sink { [weak self] val in
                self?.connectBpmSubscriberIfNeeded()
            }
    }

    private func connectBpmSubscriberIfNeeded() {
        if bpmSubscriber != nil {
            return
        }
        
        self.bpmSubscriber = self.workoutService
            .getActiveWorkoutDataPublisher()?
            .bpmPublisher
            .sink{[weak self] bpm in
                self?.handleBpmChange(bpm: bpm)
            }
    }
    
    private func handleBpmChange(bpm: Int) {
        let newZone = evaluateHeartZone(bpm: bpm)
        if currentHeartZonePublisher.value != newZone {
            self.currentHeartZonePublisher.send(newZone)
        }
    }
    
    private func evaluateHeartZone(bpm: Int) -> HeartZone? {
        let activeZone = activeHeartZoneSetting.zones.first { $0.bpmRange.contains(bpm) }
        guard let activeZone = activeZone else {
            print("Evaluated bpm of value \(bpm) is not in of evaluated zones")
            return nil
        }
        return activeZone
    }
    
    func getHeartZonePublisher() -> AnyPublisher<HeartZone, Never> {
        return currentHeartZonePublisher
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
}
