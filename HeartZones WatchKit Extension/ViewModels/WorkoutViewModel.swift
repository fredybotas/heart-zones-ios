//
//  WorkoutViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import Foundation
import SwiftUI
import Combine

fileprivate let kSecondsInHour = 3600.0
fileprivate let kSecondsForThreeQuartersOfHour = (kSecondsInHour / 4.0) * 3.0

class WorkoutViewModel: ObservableObject {
    @Published private(set) var bpm: String = "--"
    @Published private(set) var bpmUnit: String = "BPM"
    @Published private(set) var bpmCircleColor = Color.black
    @Published private(set) var bpmCircleRatio = 0.0
    
    @Published private(set) var sunsetLeft = 0
    @Published private(set) var sunVisibility = 0.0

    @Published private(set) var time: String = "00:00,00"
    @Published private(set) var energy: String = "0"
    @Published private(set) var energyUnit: String = "KCAL"

    @Published private(set) var distance: String = "0"
    @Published private(set) var distanceUnit: String = "M"

    @Published private(set) var currentPace: String = "--'--''"
    @Published private(set) var averagePace: String = "--'--''"
    
    private var sunset: Date?
    
    private let distanceFormatter = MeasurementFormatter()
    private let energyFormatter = MeasurementFormatter()

    private let workoutService: IWorkoutService
    private let heartZoneService: IHeartZoneService
    private let sunService: ISunService
    private let settingsService: ISettingsService

    private let workoutType: WorkoutType
    
    private var timer: AnyCancellable?
    private var sunsetTimer: AnyCancellable?
    private var sunsetSubscription: AnyCancellable?
    
    private var workoutDistanceDataSubscriber: AnyCancellable?
    private var workoutHeartDataSubscriber: AnyCancellable?
    private var workoutEnergyDataSubscriber: AnyCancellable?

    private var appStateChangeSubscriber: AnyCancellable?

    init(workoutType: WorkoutType, workoutService: IWorkoutService, heartZoneService: IHeartZoneService, sunService: ISunService, settingsService: ISettingsService) {
        self.workoutService = workoutService
        self.heartZoneService = heartZoneService
        self.sunService = sunService
        self.workoutType = workoutType
        self.settingsService = settingsService
        
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.unitStyle = .medium
        
        energyFormatter.unitOptions = .providedUnit
        energyFormatter.unitStyle = .medium
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
        
        setSunsetSubscriptions()
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
                // TODO: Refactor
                self?.currentPace = data.currentSpeed.toPaceString()
                self?.averagePace = data.averageSpeed.toPaceString()
                // TODO: Change to optional without forcing
                var unit: UnitLength!
                if data.distance < Measurement.init(value: 1, unit: UnitLength.kilometers) {
                    self?.distanceFormatter.numberFormatter.maximumFractionDigits = 0
                    unit = UnitLength.meters
                } else if data.distance >= Measurement.init(value: 100, unit: UnitLength.kilometers) {
                    self?.distanceFormatter.numberFormatter.maximumFractionDigits = 0
                    unit = UnitLength.kilometers
                } else {
                    self?.distanceFormatter.numberFormatter.maximumFractionDigits = 1
                    self?.distanceFormatter.numberFormatter.minimumFractionDigits = 1
                    unit = UnitLength.kilometers
                }
                let distanceString = self?.distanceFormatter.numberFormatter.string(from: NSNumber(value: data.distance.converted(to: unit).value))
                // TODO: Fix this hack
                let unitString = self?.distanceFormatter.string(from: data.distance.converted(to: unit)).split(separator: " ")[1]

                guard let distanceString = distanceString else { return }
                guard let unitString = unitString else { return }

                self?.distance = distanceString
                self?.distanceUnit = unitString.uppercased()
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
                self?.bpm = String(data.0)
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
                guard let energyString = self?.energyFormatter.numberFormatter.string(from: NSNumber(value: data.value)) else { return }
                guard let energyUnit = self?.energyFormatter.string(from: data.unit) else { return }
                self?.energy = energyString
                self?.energyUnit = energyUnit.uppercased()
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
    
    private func setSunsetSubscriptions() {
        sunsetSubscription = self.sunService
            .getSunset()
            .sink { [weak self] sunset in
                self?.sunset = sunset
            }
        sunsetTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink() { [weak self] _ in
                guard let sunset = self?.sunset else { return }
                let date = Date()
                let interval = sunset.timeIntervalSince(date)
                if interval < kSecondsForThreeQuartersOfHour && interval >= 0 {
                    self?.sunVisibility = (Double(interval) / kSecondsInHour)
                    self?.sunsetLeft = Int((interval / 60.0).rounded(.up))
                } else {
                    self?.sunVisibility = 0.0
                    self?.sunsetLeft = 0
                }
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
            return String(format: "%0.3d:%0.2d,%0.1d", minutes, seconds, ms / 100)
        } else {
            return String(format: "%0.2d:%0.2d,%0.2d", minutes, seconds, ms / 10)
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

