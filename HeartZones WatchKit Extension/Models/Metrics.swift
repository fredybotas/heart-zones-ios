//
//  Metrics.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 01/08/2021.
//

import Foundation

struct DistanceMetric: Identifiable, Codable, Hashable {
    enum MetricType: String, Codable, Hashable {
        case km = "km", mi = "mi"
    }
    let id: UInt
    let type: MetricType
    
    static func getPossibleMetrics() -> [DistanceMetric] {
        return [DistanceMetric(id: 0, type: .km), DistanceMetric(id: 1, type: .mi)]
    }
    
    static func getDefault(metric: Bool) -> DistanceMetric {
        if metric {
            return getPossibleMetrics()[0]
        } else {
            return getPossibleMetrics()[1]
        }
    }
}

struct EnergyMetric: Identifiable, Codable, Hashable {
    enum MetricType: String, Codable, Hashable {
        case kcal = "kcal", kj = "kJ"
    }
    let id: UInt
    let type: MetricType
    
    static func getPossibleMetrics() -> [EnergyMetric] {
        return [EnergyMetric(id: 0, type: .kcal), EnergyMetric(id: 1, type: .kj)]
    }
    
    static func getDefault() -> EnergyMetric {
        return getPossibleMetrics()[0]
    }
}

struct SpeedMetric: Identifiable, Codable, Hashable {
    enum MetricType: Int, Codable, Hashable {
        case pace, speed
    }
    let id: UInt
    let type: MetricType
    
    static func getPossibleMetrics() -> [SpeedMetric] {
        return [SpeedMetric(id: 0, type: .pace), SpeedMetric(id: 1, type: .speed)]
    }
    
    static func getDefault() -> SpeedMetric {
        return getPossibleMetrics()[0]
    }
}
