//
//  HeartZone.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import SwiftUI

struct HeartZonesSetting {
    let zones: [HeartZone]
    
    static func getDefaultHeartZonesSetting(age: Int) -> HeartZonesSetting {
        let maxBpm = Double(220 - age)
        
        return HeartZonesSetting(zones: [
            HeartZone(name: "Peak", bpmRange: Int(0.85 * maxBpm)...Int(1.00 * maxBpm), color: Color.red, target: false),
            HeartZone(name: "Cardio", bpmRange: Int(0.75 * maxBpm)...Int(0.85 * maxBpm), color: Color.orange, target: true),
            HeartZone(name: "Fat Burn", bpmRange: Int(0.6 * maxBpm)...Int(0.75 * maxBpm), color: Color.yellow, target: false),
            HeartZone(name: "Warm Up", bpmRange: Int(0 * maxBpm)...Int(0.6 * maxBpm), color: Color.green, target: false),
        ])
    }
}

struct HeartZone: Equatable {
    let name: String
    let bpmRange: ClosedRange<Int>
    let color: Color
    let target: Bool
    
    func getBpmRatio(bpm: Int) -> Double? {
        guard let first = bpmRange.first, let last = bpmRange.last else {
            return nil
        }
        let result = Double(bpm - first) / Double(last - first)
        if result < 0 || result > 1 {
            return nil
        }
        return result
    }
    
    static func ==(lhs: HeartZone, rhs: HeartZone) -> Bool {
        return lhs.name == rhs.name
            && lhs.bpmRange == rhs.bpmRange
            && lhs.color == rhs.color
            && lhs.target == rhs.target
    }
}
