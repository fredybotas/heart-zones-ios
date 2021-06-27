//
//  WorkoutViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import SwiftUI
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var isRunning: Bool = true
    
    @Published var bpm: String = "-- bpm"    
    @Published var bpmCircleColor = Color.green
    @Published var bpmCircleRatio = 0.25
    
    @Published var time: String = "--:--,--"
    @Published var energy: String = "-- kcal"
    @Published var distance: String = "-- km"
    @Published var currentPace: String = "--'--''"
    @Published var averagePace: String = "--'--''"

    private let workoutService: IWorkoutService = WorkoutService()
    //TODO: Get correct age
    private let heartZoneService: HeartZoneService = HeartZoneService(age: 25)
    private var timer: AnyCancellable?
    
    init(workoutType: WorkoutType) {
        workoutService.startWorkout(workoutType: workoutType)
        startTimer()
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink() { _ in
                guard let newTimeInterval = self.workoutService.getActiveWorkoutElapsedTime() else {
                    return
                }
                self.time = newTimeInterval.stringFromTimeInterval()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
    }
    
    func pauseWorkout() {
        workoutService.pauseActiveWorkout()
        stopTimer()
        isRunning = false
    }
    
    func resumeWorkout() {
        workoutService.resumeActiveWorkout()
        startTimer()
        isRunning = true
    }
    
    func stopWorkout() {
        workoutService.stopActiveWorkout()
        stopTimer()
        isRunning = false
    }
    
}

fileprivate extension TimeInterval{

        func stringFromTimeInterval() -> String {

            let time = NSInteger(self)

            let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
            let seconds = time % 60
            let minutes = (time / 60) % 60

            if minutes >= 100 {
                return String(format: "%0.3d:%0.2d,%0.2d",minutes,seconds,ms / 10)
            } else {
                return String(format: "%0.2d:%0.2d,%0.2d",minutes,seconds,ms / 10)
            }
        }
    }
