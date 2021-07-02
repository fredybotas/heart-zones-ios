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
    @Published var bpmCircleColor = Color.black
    @Published var bpmCircleRatio = 0.0
    
    @Published var time: String = "00:00,00"
    @Published var energy: String = "0 kcal"
    @Published var distance: String = "0 km"
    @Published var currentPace: String = "--'--''"
    @Published var averagePace: String = "--'--''"
    
    let distanceFormatter = MeasurementFormatter()
    let energyFormatter = MeasurementFormatter()

    private let workoutService: IWorkoutService
    private let heartZoneService: HeartZoneService
    private let workoutType: WorkoutType
    
    private var timer: AnyCancellable?

    private var workoutDistanceDataSubscriber: AnyCancellable?
    private var workoutBpmDataSubscriber: AnyCancellable?
    private var workoutEnergyDataSubscriber: AnyCancellable?

    init(workoutType: WorkoutType, workoutService: IWorkoutService, heartZoneService: HeartZoneService) {
        self.workoutService = workoutService
        self.heartZoneService = heartZoneService
        self.workoutType = workoutType
        
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.numberFormatter.maximumFractionDigits = 1
        
        energyFormatter.unitOptions = .providedUnit
        energyFormatter.numberFormatter.maximumFractionDigits = 0
    }
    
    deinit {
        stopTimer()
    }
    
    func startWorkout() {
        workoutService.startWorkout(workoutType: workoutType)
        
        setDistanceSubscriber()
        setBpmSubscriber()
        setEnergySubscriber()
        
        startTimer()
    }
    
    func setDistanceSubscriber() {
        workoutDistanceDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .distancePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutDistanceDataSubscriber?.cancel()
                self?.workoutDistanceDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                self?.currentPace = data.currentSpeed.toPaceString()
                self?.averagePace = data.averageSpeed.toPaceString()
                guard let distanceString = self?.distanceFormatter.string(from: data.distance.converted(to: UnitLength.kilometers)) else { return }
                self?.distance = distanceString
            })
    }
    
    func setBpmSubscriber() {
        workoutBpmDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .bpmPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutBpmDataSubscriber?.cancel()
                self?.workoutBpmDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                self?.bpm = String(data) + " bpm"
                guard let zone = self?.heartZoneService.evaluateHeartZone(bpm: data) else { return }
                self?.bpmCircleColor = zone.color
                guard let ratio = zone.getBpmRatio(bpm: data) else { return }
                self?.bpmCircleRatio = ratio
            })
    }
    
    func setEnergySubscriber() {
        workoutEnergyDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .energyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutEnergyDataSubscriber?.cancel()
                self?.workoutEnergyDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                guard let energyString = self?.energyFormatter.string(from: data) else { return }
                self?.energy = energyString
            })
    }
    
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink() { [weak self] _ in
                guard let newTimeInterval = self?.workoutService.getActiveWorkoutElapsedTime() else {
                    return
                }
                self?.time = newTimeInterval.stringFromTimeInterval()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}

fileprivate extension TimeInterval {

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

fileprivate extension Measurement where UnitType == UnitSpeed {
    func toPaceString() -> String {
        let metresPerSec = self.converted(to: UnitSpeed.metersPerSecond).value
        if metresPerSec == 0 {
            return "--'--''"
        }
        let kilometresPerSec = metresPerSec / 1000
        let secsForKilometer = Int.init(1 / kilometresPerSec)
        return String(format: "%0.2d'%0.2d''", secsForKilometer / 60, secsForKilometer % 60)
    }
}
