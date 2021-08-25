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
    @Published private(set) var time: String = "00:00,00"
    
    @Published private(set) var energy: String
    @Published private(set) var energyUnit: String

    @Published private(set) var distance: String
    @Published private(set) var distanceUnit: String

    @Published private(set) var currentPace: String
    @Published private(set) var averagePace: String
    
    @Published private(set) var bpm: String = "--"
    @Published private(set) var bpmUnit: String = "BPM"
    
    @Published private(set) var bpmCircleColor = Color.black
    @Published private(set) var bpmCircleRatio = 0.0
    
    @Published private(set) var sunsetLeft = 0
    @Published private(set) var sunVisibility = 0.0

    private var sunset: Date?
    
    private let workoutService: IWorkoutService
    private let heartZoneService: IHeartZoneService
    private let sunService: ISunService
    private let settingsService: ISettingsService

    private let workoutType: WorkoutType
    
    private let energyShowingStrategy: IEnergyShowingStrategy
    private let distanceShowingStrategy: IDistanceShowingStrategy

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
        
        switch self.settingsService.selectedEnergyMetric.type {
        case .kj:
            self.energyShowingStrategy = EnergyKJShowingStrategy()
        case .kcal:
            self.energyShowingStrategy = EnergyKcalShowingStrategy()
        }
        
        switch self.settingsService.selectedDistanceMetric.type {
        case .km:
            switch self.settingsService.selectedSpeedMetric.type {
            case .pace:
                self.distanceShowingStrategy = MetricDistanceWithPaceShowingStrategy()
            case .speed:
                self.distanceShowingStrategy = MetricDistanceWithSpeedShowingStrategy()
            }
        case .mi:
            switch self.settingsService.selectedSpeedMetric.type {
            case .pace:
                self.distanceShowingStrategy = MilleageDistanceWithPaceShowingStrategy()
            case .speed:
                self.distanceShowingStrategy = MilleageDistanceWithSpeedShowingStrategy()
            }
        }
        
        self.energy = self.energyShowingStrategy.defaultEnerguValue
        self.energyUnit = self.energyShowingStrategy.defaultEnergyUnit
        
        self.distance = self.distanceShowingStrategy.defaultDistanceValue
        self.distanceUnit = self.distanceShowingStrategy.defaultDistanceUnit

        self.currentPace = self.distanceShowingStrategy.defaultPaceString
        self.averagePace = self.distanceShowingStrategy.defaultPaceString
        
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
        
        fetchSunsetDataAndSetSunsetSubscription()
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
                self?.processDistanceData(data)
            })
    }
    
    private func processDistanceData(_ data: DistanceData) {
        self.currentPace = self.distanceShowingStrategy.getCurrentPace(data)
        self.averagePace = self.distanceShowingStrategy.getAveragePace(data)
        
        let (value, unit) = self.distanceShowingStrategy.getDistanceValueAndUnit(data)
        guard let value = value else { return }
        guard let unit = unit else { return }
        
        self.distance = value
        self.distanceUnit = unit
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
                self?.processHeartData(data)
            })
    }
    
    private func processHeartData(_ data: (Int, HeartZone)) {
        self.bpm = String(data.0)
        self.bpmCircleColor = data.1.color
        guard let ratio = data.1.getBpmRatio(bpm: data.0) else { return }
        self.bpmCircleRatio = ratio
    }
    
    func setEnergySubscriber() {
        workoutEnergyDataSubscriber = workoutService
            .getActiveWorkoutDataPublisher()?
            .energyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.workoutEnergyDataSubscriber = nil
            }, receiveValue: { [weak self] data in
                self?.processEnergyData(data)
            })
    }
    
    private func processEnergyData(_ data: Measurement<UnitEnergy>) {
        energy = self.energyShowingStrategy.getEnergyValue(data) ?? energy
        energyUnit = self.energyShowingStrategy.getEnergyMetric(data)
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
    
    private func fetchSunsetDataAndSetSunsetSubscription() {
        sunsetSubscription = self.sunService
            .getSunset()
            .sink { [weak self] sunset in
                self?.sunset = sunset
                self?.updateSunsetData()
            }
        sunsetTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink() { [weak self] _ in
                self?.updateSunsetData()
            }
    }
    
    private func updateSunsetData() {
        guard let sunset = self.sunset else { return }
        let date = Date()
        let interval = sunset.timeIntervalSince(date)
        if interval < kSecondsForThreeQuartersOfHour && interval >= 0 {
            self.sunVisibility = (Double(interval) / kSecondsInHour)
            self.sunsetLeft = Int((interval / 60.0).rounded(.up))
        } else {
            self.sunVisibility = 0.0
            self.sunsetLeft = 0
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
