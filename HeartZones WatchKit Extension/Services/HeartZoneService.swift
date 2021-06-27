//
//  HeartZoneService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import SwiftUI

class HeartZoneService {
    
    private let defaultHeartZone: HeartZonesSetting
    private let age: Int
    
    init (age: Int) {
        self.age = age
        self.defaultHeartZone = HeartZonesSetting.getDefaultHeartZonesSetting(age: age)
    }
    
    func evaluateHeartZone(bpm: Int) -> (Color, Double) {
        // TODO: Add logic to evaluate correct heart zone. Now we are using default zones only.
        return (Color.red, 0.5)
    }
}
