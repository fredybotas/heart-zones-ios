//
//  WorkoutType.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import HealthKit

let typeToString: [WorkoutType.type: String] = [
    .outdoorRunning: "Outdoor Running",
    .indoorRunning: "Indoor Running",
    .walking: "Walking",
]

struct WorkoutType: Identifiable {
    enum type: Int {
        case outdoorRunning, indoorRunning, walking
    }
    var type: type
    var name: String {
        get {
            return typeToString[self.type]!
        }
    }
    var id: Int {
        get {
            return self.type.rawValue
        }
    }
    
    func getConfiguration() -> HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        //TODO: Add support for more configurations
        switch self.type {
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
