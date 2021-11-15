//
//  Containers.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 01/07/2021.
//

import Foundation
import CoreLocation

struct BpmContainer {
    private var array = [(Int, TimeInterval)]()
    private let size: UInt
    private let targetHeartZone: HeartZone
    private(set) var timeInTargetZone: TimeInterval = 0
    private(set) var bpmDuration: TimeInterval = 0
    private let maxBpm: Int
    
    init(size: UInt, targetHeartZone: HeartZone, maxBpm: Int) {
        self.size = size
        self.targetHeartZone = targetHeartZone
        self.maxBpm = maxBpm
    }
    
    mutating func insert(bpm: Int) {
        if let lastElement = array.last {
            let timestamp = Date().timeIntervalSince1970
            if targetHeartZone.getBpmRange(maxBpm: maxBpm).contains(lastElement.0) {
                timeInTargetZone += timestamp - lastElement.1
            }
            bpmDuration += timestamp - lastElement.1
        }
        array.append((bpm, Date().timeIntervalSince1970))
        if array.count > size {
            array.remove(at: 0)
        }
    }
    
    func timeInTargetZonePercentage() -> Int {
        let bpmTimeRatio = timeInTargetZone / bpmDuration
        if bpmTimeRatio.isNaN || bpmTimeRatio.isInfinite {
            return 0
        }
        return Int(bpmTimeRatio * 100)
    }
    
    func getActualBpm() -> Int? {
        if array.count < size || array.count == 0 {
            return nil
        }
        return array.map{$0.0}.reduce(0, { $0 + $1 }) / array.count
    }
}

struct DistanceContainer {
    private var distances = [Double]()
    private var timeIntervals = [TimeInterval]()
    
    private let size: UInt
    
    init(size: UInt) {
        self.size = size
    }
    
    mutating func insert(distance: Double, timeInterval: TimeInterval) {
        distances.append(distance)
        timeIntervals.append(timeInterval)
        if distances.count > size {
            distances.remove(at: 0)
            timeIntervals.remove(at: 0)
        }
    }
    
    func getAverageSpeed() -> Measurement<UnitSpeed>? {
        if distances.count < size {
            return nil
        }
        let distance = distances.reduce(0, { $0 + $1 })
        let time = timeIntervals.reduce(0, { $0 + $1 })
        
        if distance.isNaN || distance.isInfinite || time.isInfinite || time.isZero || time.isNaN {
            return nil
        }
        return Measurement(value:  distance / time, unit: UnitSpeed.metersPerSecond)
    }
}

struct SameElementsContainer<T: Equatable> {
    private var elements = [T]()
    
    var count: Int {
        get {
            return self.elements.count
        }
    }
    
    mutating func RefreshAndInsert(element: T) {
        if elements.allSatisfy({ $0 == element }) {
            elements.append(element)
        } else {
            elements.removeAll()
            elements.append(element)
        }
    }
    
    mutating func removeAll() {
        elements.removeAll()
    }
}

struct ElevationContainer {
    private var lastElement: Double?
    private var currentElement: Double?
    private var elevationGained: Double = 0.0
    
    private var minElevation: Double = Double.infinity
    private var maxElevation: Double = -Double.infinity
    
    mutating func insertLocation(loc: CLLocation) {
        let elevation = loc.altitude
        if elevation < minElevation {
            minElevation = elevation
        }
        if elevation > maxElevation {
            maxElevation = elevation
        }
        
        lastElement = currentElement
        currentElement = elevation
        
        if let lastElement = lastElement, let currentElement = currentElement {
            if currentElement > lastElement {
                elevationGained += currentElement - lastElement
            }
        }
    }
    
    func getMinElevation() -> Measurement<UnitLength>? {
        if minElevation == Double.infinity {
            return nil
        }
        return Measurement.init(value: minElevation, unit: UnitLength.meters)
    }
    
    func getMaxElevation() -> Measurement<UnitLength>? {
        if maxElevation == -Double.infinity {
            return nil
        }
        return Measurement.init(value: maxElevation, unit: UnitLength.meters)
    }
    
    func getElevationGain() -> Measurement<UnitLength>? {
        if elevationGained == 0 {
            return nil
        }
        return Measurement.init(value: elevationGained, unit: UnitLength.meters)
    }
}

