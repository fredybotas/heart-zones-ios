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
        if array.count < size || array.count == 0 {
            return nil
        }
        return array.reduce(0, { $0 + $1 }) / array.count
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

