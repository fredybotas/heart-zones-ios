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
    @Published private(set) var bpm: String = "-- bpm"
    @Published private(set) var bpmCircleColor = Color.black
    @Published private(set) var bpmCircleRatio = 0.0
    
    @Published private(set) var sunVisibility = 0.0
    
    @Published private(set) var time: String = "00:00,00"
    @Published private(set) var energy: String = "0 kcal"
    @Published private(set) var distance: String = "0 km"
    @Published private(set) var currentPace: String = "--'--''"
    @Published private(set) var averagePace: String = "--'--''"
    
    
    private let distanceFormatter = MeasurementFormatter()
    private let energyFormatter = MeasurementFormatter()

    private let workoutService: IWorkoutService
    private let heartZoneService: IHeartZoneService
    private let workoutType: WorkoutType
    
    private var timer: AnyCancellable?

    private var workoutDistanceDataSubscriber: AnyCancellable?
    private var workoutHeartDataSubscriber: AnyCancellable?
    private var workoutEnergyDataSubscriber: AnyCancellable?

    private var appStateChangeSubscriber: AnyCancellable?

    init(workoutType: WorkoutType, workoutService: IWorkoutService, heartZoneService: IHeartZoneService) {
        self.workoutService = workoutService
        self.heartZoneService = heartZoneService
        self.workoutType = workoutType
        
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.numberFormatter.maximumFractionDigits = 1
        distanceFormatter.numberFormatter.minimumFractionDigits = 1
            
        energyFormatter.unitOptions = .providedUnit
        energyFormatter.numberFormatter.maximumFractionDigits = 0
    
        if let delegate = WKExtension.shared().delegate as? ExtensionDelegate {
            appStateChangeSubscriber = delegate.appStateChangePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] state in
                    if state == .background {
                        self?.startTimer(slow: true)
                    } else {
                        self?.startTimer(slow: false)
                    }
                })
        } else {
            startTimer(slow: false)
        }
    }
    
    func startWorkout() {
        workoutService.startWorkout(workoutType: workoutType)
        
        // TODO: Connect to workout state. Add workout state listener first
        setDistanceSubscriber()
        setHeartDataSubscriber()
        setEnergySubscriber()
    }
    
    func setDistanceSubscriber() {
        workoutDistanceDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .distancePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutDistanceDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                self?.currentPace = data.currentSpeed.toPaceString()
                self?.averagePace = data.averageSpeed.toPaceString()
                var distanceString: String?
                if data.distance < Measurement.init(value: 1, unit: UnitLength.kilometers) {
                    distanceString = self?.distanceFormatter.string(from: data.distance.converted(to: UnitLength.meters))
                } else {
                    distanceString = self?.distanceFormatter.string(from: data.distance.converted(to: UnitLength.kilometers))
                }
                guard let distanceString = distanceString else { return }
                self?.distance = distanceString
            })
    }
    
    func setHeartDataSubscriber() {
        workoutHeartDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .bpmPublisher
            .combineLatest(heartZoneService
                            .getHeartZonePublisher())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutHeartDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                self?.bpm = String(data.0) + " bpm"
                self?.bpmCircleColor = data.1.color
                guard let ratio = data.1.getBpmRatio(bpm: data.0) else { return }
                self?.bpmCircleRatio = ratio
            })
    }
    
    func setEnergySubscriber() {
        workoutEnergyDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .energyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutEnergyDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                guard let energyString = self?.energyFormatter.string(from: data) else { return }
                self?.energy = energyString
            })
    }
    
    private func startTimer(slow: Bool) {
        timer = Timer.publish(every: slow ? 0.5 : 0.05, on: .main, in: .common)
            .autoconnect()
            .sink() { [weak self] _ in
                guard let newTimeInterval = self?.workoutService.getActiveWorkoutElapsedTime() else {
                    return
                }
                self?.time = newTimeInterval.stringFromTimeInterval()
            }
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

