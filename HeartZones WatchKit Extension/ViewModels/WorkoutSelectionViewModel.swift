//
//  WorkoutSelectionViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/06/2021.
//

import Foundation

class WorkoutSelectionViewModel: ObservableObject {
 
    var workoutTypes: [WorkoutType] = [WorkoutType(type: .outdoorRunning), WorkoutType(type: .indoorRunning), WorkoutType(type: .walking)]

}
