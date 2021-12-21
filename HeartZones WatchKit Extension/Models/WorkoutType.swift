//
//  WorkoutType.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import HealthKit

let typeToString: [WorkoutType.TypeValues: String] = [
    .outdoorRunning: "Outdoor Run",
    .indoorRunning: "Indoor Run",
    .walking: "Walking"
]

struct WorkoutType: Identifiable {
    enum TypeValues: Int {
        case outdoorRunning, indoorRunning, walking
    }

    var type: TypeValues
    var name: String {
        return typeToString[type]!
    }

    var id: Int {
        return type.rawValue
    }

    func getConfiguration() -> HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        // TODO: Add support for more configurations
        switch type {
        case .outdoorRunning:
            configuration.activityType = .running
            configuration.locationType = .outdoor
        case .indoorRunning:
            configuration.activityType = .running
            configuration.locationType = .indoor
        case .walking:
            configuration.activityType = .walking
            configuration.locationType = .outdoor
        }

        return configuration
    }
}
