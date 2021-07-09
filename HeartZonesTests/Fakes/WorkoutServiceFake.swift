//
//  WorkoutServiceFake.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 09/07/2021.
//

import Foundation
import Combine
@testable import HeartZones_WatchKit_Extension

class WorkoutServiceFake: IWorkoutService {
    
    private let dataPublishers = WorkoutDataChangePublishers()
    private let statePublisher = PassthroughSubject<WorkoutState, Never>()
    
    func startWorkout(workoutType: WorkoutType) {}
    func stopActiveWorkout() {}
    func pauseActiveWorkout() {}
    func resumeActiveWorkout() {}
    func getActiveWorkoutElapsedTime() -> TimeInterval? {return nil}
    
    func sendBpmChange(bpm: Int) {
        dataPublishers.bpmPublisher.send(bpm)
    }
    
    func changeState(state: WorkoutState) {
        statePublisher.send(state)
    }
    
    func getActiveWorkoutDataPublisher() -> WorkoutDataChangePublishers? {
        return dataPublishers
    }
    
    func getWorkoutStatePublisher() -> AnyPublisher<WorkoutState, Never> {
        return statePublisher.eraseToAnyPublisher()
    }
}
