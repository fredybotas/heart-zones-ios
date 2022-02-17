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
    .outdoorCycling: "Outdoor Cycling",
    .indoorCycling: "Indoor Cycling",
    .walking: "Walking",
    .hiit: "HIIT"
]

struct WorkoutType: Identifiable {
    enum TypeValues: Int {
        case outdoorRunning, indoorRunning, outdoorCycling, indoorCycling, walking, hiit
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
        case .hiit:
            configuration.activityType = .highIntensityIntervalTraining
            configuration.locationType = .unknown
        case .outdoorCycling:
            configuration.activityType = .cycling
            configuration.locationType = .outdoor
        case .indoorCycling:
            configuration.activityType = .cycling
            configuration.locationType = .indoor
        }

        return configuration
    }

    static func configurationToType(configuration: HKWorkoutConfiguration) -> WorkoutType {
        // TODO: Refactor
        if configuration.activityType == .running {
            if configuration.locationType == .indoor {
                return WorkoutType(type: .indoorRunning)
            } else if configuration.locationType == .outdoor {
                return WorkoutType(type: .outdoorRunning)
            }
        } else if configuration.activityType == .walking {
            if configuration.locationType == .outdoor {
                return WorkoutType(type: .walking)
            }
        } else if configuration.activityType == .highIntensityIntervalTraining {
            return WorkoutType(type: .hiit)
        }
        return WorkoutType(type: .outdoorRunning)
    }
}
