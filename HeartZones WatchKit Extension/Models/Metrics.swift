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
