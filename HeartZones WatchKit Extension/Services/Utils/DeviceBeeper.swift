//
//  DeviceBeeper.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 29/07/2021.
//

import Foundation
import WatchKit

protocol IDeviceBeeper {
    func runHighRateAlert()
    func runLowRateAlert()
}

class DeviceBeeper: IDeviceBeeper {
    func runHighRateAlert() {
        WKInterfaceDevice().play(.failure)
    }

    func runLowRateAlert() {
        WKInterfaceDevice().play(.notification)
    }
}

private let kBeepMinimumDelay: Double = 0.5

class DeviceBeeperDelayProxy: IDeviceBeeper {
    let deviceBeeper = DeviceBeeper()
    let queue = DispatchQueue.main

    var lastBeep = DispatchTime.now()

    private func getNextRun() -> DispatchTime {
        if DispatchTime.now() >= lastBeep + kBeepMinimumDelay {
            lastBeep = .now()
            return .now()
        } else {
            // swiftlint:disable:next shorthand_operator
            lastBeep = lastBeep + kBeepMinimumDelay
            return lastBeep + kBeepMinimumDelay
        }
    }

    func runHighRateAlert() {
        queue.asyncAfter(deadline: getNextRun()) {
            self.deviceBeeper.runHighRateAlert()
        }
    }

    func runLowRateAlert() {
        queue.asyncAfter(deadline: getNextRun()) {
            self.deviceBeeper.runLowRateAlert()
        }
    }
}
