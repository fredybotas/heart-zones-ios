//
//  DeviceBeeper.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/07/2021.
//

import Combine
import Foundation
import WatchKit

protocol BeepingManager {
    var isLowRateAlertRunning: Bool { get }
    var isHighRateAlertRunning: Bool { get }

    func startHighRateAlert()
    func startLowRateAlert()
    func stopHighRateAlert()
    func stopLowRateAlert()

    func runOnceHighRateAlert()
    func runOnceLowRateAlert()
}

private let kZoneAlertInterval: TimeInterval = 7.0

class DeviceBeepingManager: BeepingManager {
    var isLowRateAlertRunning: Bool {
        return timerLowRate != nil
    }

    var isHighRateAlertRunning: Bool {
        return timerHighRate != nil
    }

    private let beeper: IDeviceBeeper

    private var timerHighRate: AnyCancellable?
    private var timerLowRate: AnyCancellable?
    private var appStateChangeSubscriber: AnyCancellable?

    init(beeper: IDeviceBeeper) {
        self.beeper = beeper
    }

    func runOnceHighRateAlert() {
        beeper.runHighRateAlert()
    }

    func runOnceLowRateAlert() {
        beeper.runLowRateAlert()
    }

    func startHighRateAlert() {
        beeper.runHighRateAlert()
        timerHighRate = Timer.TimerPublisher(
            interval: kZoneAlertInterval, runLoop: .main, mode: .common
        )
        .autoconnect()
        .sink { _ in
            self.beeper.runHighRateAlert()
        }
    }

    func startLowRateAlert() {
        beeper.runLowRateAlert()
        timerLowRate = Timer.TimerPublisher(
            interval: kZoneAlertInterval, runLoop: .main, mode: .common
        )
        .autoconnect()
        .sink { _ in
            self.beeper.runLowRateAlert()
        }
    }

    func stopHighRateAlert() {
        timerHighRate = nil
    }

    func stopLowRateAlert() {
        timerLowRate = nil
    }
}
