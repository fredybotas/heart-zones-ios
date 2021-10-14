//
//  HeartZone.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import SwiftUI

struct HeartZonesSetting: Codable, Hashable {
    enum HeartZoneMovement {
        case up, down, stay, undefined
    }
    
    var zones: [HeartZone]
    
    func evaluateBpmChange(currentZone: HeartZone?, bpm: Int, maxBpm: Int) -> (HeartZoneMovement, HeartZone?) {
        let newZone = zones.first { $0.getBpmRange(maxBpm: maxBpm).contains(bpm) }
        guard let newZone = newZone else {
            // BPM not in range
            if let firstZone = zones.first, bpm <= firstZone.getBpmRange(maxBpm: maxBpm).lowerBound {
                return (.undefined, zones.first)
            } else if let lastZone = zones.last, bpm >= lastZone.getBpmRange(maxBpm: maxBpm).upperBound {
                return (.undefined, zones.last)
            } else {
                return (.undefined, nil)
            }
        }
        guard let currentZone = currentZone else {
            return (.undefined, newZone)
        }
        
        if currentZone == newZone {
            return (.stay, nil)
        } else if currentZone.getBpmRange(maxBpm: maxBpm).upperBound <= newZone.getBpmRange(maxBpm: maxBpm).lowerBound {
            return (.up, newZone)
        } else {
            return (.down, newZone)
        }
    }
    
    var zonesCount: Int {
        get {
            zones.count
        }
    }

    static func getMaximumBpm(age: Int) -> Int {
        return 220 - age
    }
    
    static func getPossibleZoneCounts() -> [Int] {
        return [4]
    }
    
    static func getDefaultHeartZonesSetting() -> HeartZonesSetting {
        return HeartZonesSetting(zones: [
            HeartZone(id: 0, name: "Zone 1", bpmRangePercentage: 0...60, color: HeartZone.Color.init(red: 36 / 255, green: 123 / 255, blue: 160 / 255) , target: false),
            HeartZone(id: 1, name: "Zone 2", bpmRangePercentage: 60...75, color: HeartZone.Color.init(red: 140 / 255, green: 179 / 255, blue: 105 / 255), target: false),
            HeartZone(id: 2, name: "Zone 3", bpmRangePercentage: 75...85, color: HeartZone.Color.init(red: 250 / 255, green: 159 / 255, blue: 66 / 255), target: true),
            HeartZone(id: 3, name: "Zone 4", bpmRangePercentage: 85...100, color: HeartZone.Color.init(red: 221 / 255, green: 4 / 255, blue: 38 / 255), target: false)
        ])
    }
    
    mutating func setTargetZone(targetZoneId: Int) {
        for i in 0..<zones.count {
            zones[i].target = false
            if zones[i].id == targetZoneId {
                zones[i].target = true
            }
        }
    }
}

struct HeartZone: Equatable, Hashable, Identifiable, Codable {
    struct Color: Equatable, Hashable, Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        func toColor() -> SwiftUI.Color {
            return SwiftUI.Color.init(red: red, green: green, blue: blue)
        }
    }

    let id: Int
    let name: String
    let bpmRangePercentage: ClosedRange<Int>
    let color: Color
    var target: Bool
    
    func getBpmRatio(bpm: Int, maxBpm: Int) -> Double? {
        let first = Int((Double(bpmRangePercentage.lowerBound) / 100.0) * Double(maxBpm))
        let last = Int((Double(bpmRangePercentage.upperBound) / 100.0) * Double(maxBpm))
        
        let result = Double(bpm - first) / Double(last - first)
        if result < 0 {
            return 0.0
        }
        if result > 1 {
            return 1.0
        }
        return result
    }
    
    func getBpmRange(maxBpm: Int) -> ClosedRange<Int> {
        return Int((Double(bpmRangePercentage.lowerBound) / 100.0) * Double(maxBpm))...Int((Double(bpmRangePercentage.upperBound) / 100.0) * Double(maxBpm))
    }
    
    static func ==(lhs: HeartZone, rhs: HeartZone) -> Bool {
        return lhs.name == rhs.name
            && lhs.bpmRangePercentage == rhs.bpmRangePercentage
            && lhs.color == rhs.color
            && lhs.target == rhs.target
    }
}
