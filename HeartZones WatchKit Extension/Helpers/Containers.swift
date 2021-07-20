//
//  Containers.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 01/07/2021.
//

import Foundation

struct BpmContainer {
    private var array = [Int]()
    private let size: UInt
    
    init(size: UInt) {
        self.size = size
    }
    
    mutating func insert(bpm: Int) {
        array.append(bpm)
        if array.count > size {
            array.remove(at: 0)
        }
    }
    
    func getActualBpm() -> Int? {
        if array.count < size {
            return nil
        }
        return array.reduce(0, { $0 + $1 }) / array.count
    }
}

/*
 @discussion    Calculation is not accurate now.
                Lap average speed might be calculated from more than lapSize parameter.
 */
struct DistanceContainer {
    private var distanceSum = 0.0
    private var timeSum = 0.0
    
    private let lapSize: Double
    
    init(lapSize: Double) {
        self.lapSize = lapSize
    }
    
    mutating func insert(distance: Double, timeInterval: TimeInterval) {
        if distanceSum >= lapSize {
            distanceSum = 0.0
            timeSum = 0.0
        }
        // TODO: Think of more accurate way to calculate average speed. Maybe interpolate last given distance and its interval to fill lapSize exactly
        
        distanceSum += distance
        timeSum += timeInterval
    }
    
    func getAverageSpeed() -> Measurement<UnitSpeed>? {
        return Measurement(value: distanceSum / timeSum, unit: UnitSpeed.metersPerSecond)
    }
}
