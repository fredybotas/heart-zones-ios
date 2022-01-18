//
//  WorkoutActiveTimeProcessor.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 18/01/2022.
//

import Foundation

struct WorkoutEvent {
    enum Event: Int {
        case pauseWorkout, resumeWorkout
    }

    let type: Event
    let date: Date
}

class WorkoutActiveTimeProcessor {
    func getActiveTimeSegmentsForWorkout(startDate _: Date?, endDate _: Date?, workoutEvents _: [WorkoutEvent]) -> [(Date, Date)] {
        return []
    }
}
