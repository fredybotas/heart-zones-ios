//
//  HeartZoneService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import SwiftUI
import os

class HeartZoneService {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "heart_zone_service")
    private let defaultHeartZone: HeartZonesSetting
    private let age: Int
    
    init (age: Int) {
        self.age = age
        self.defaultHeartZone = HeartZonesSetting.getDefaultHeartZonesSetting(age: age)
    }
    
    func evaluateHeartZone(bpm: Int) -> HeartZone? {
        // TODO: Add logic to evaluate correct heart zone. Now we are using default zones only.
        let activeZone = defaultHeartZone.zones.first { $0.bpmRange.contains(bpm) }
        guard let activeZone = activeZone else {
            logger.info("Evaluated bpm of value \(bpm) is not in of evaluated zones")
            return nil
        }
        return activeZone
    }
    
}
