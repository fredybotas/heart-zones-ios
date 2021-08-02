//
//  HeartZone.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import SwiftUI

struct HeartZonesSetting {
    
    enum HeartZoneMovement {
        case up, down, stay, undefined
    }
    
    let zones: [HeartZone]
    
    func evaluateBpmChange(currentZone: HeartZone?, bpm: Int) -> (HeartZoneMovement, HeartZone?) {
        let newZone = zones.first { $0.bpmRange.contains(bpm) }
        guard let newZone = newZone else {
            return (.stay, nil)
        }
        guard let currentZone = currentZone else {
            return (.undefined, newZone)
        }
        
        if currentZone == newZone {
            return (.stay, nil)
        } else if currentZone.bpmRange.upperBound <= newZone.bpmRange.lowerBound {
            return (.up, newZone)
        } else {
            return (.down, newZone)
        }
    }
    
    static func getMaximumBpm(age: Int) -> Int {
        return 220 - age
    }
    
    static func getDefaultHeartZonesSetting(maximumBpm: Int) -> HeartZonesSetting {
        let maxBpm = Double(maximumBpm)
        return HeartZonesSetting(zones: [
            HeartZone(name: "Light", bpmRange: Int(0 * maxBpm)...Int(0.6 * maxBpm), color: Color.green, target: false),
            HeartZone(name: "Moderate", bpmRange: Int(0.6 * maxBpm)...Int(0.75 * maxBpm), color: Color.yellow, target: false),
            HeartZone(name: "Hard", bpmRange: Int(0.75 * maxBpm)...Int(0.85 * maxBpm), color: Color.orange, target: true),
            HeartZone(name: "Peak", bpmRange: Int(0.85 * maxBpm)...Int(1.0 * maxBpm), color: Color.red, target: false),
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
        if result < 0 {
            return 0.0
        }
        if result > 1 {
            return 1.0
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
