//
//  WorkoutType.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation
import HealthKit

struct WorkoutType: Identifiable {
    var name: String
    var id: Int
    
    func getConfiguration() -> HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        //TODO: Add support for more configurations
        configuration.activityType = .running
        configuration.locationType = .outdoor
        return configuration
    }
}
