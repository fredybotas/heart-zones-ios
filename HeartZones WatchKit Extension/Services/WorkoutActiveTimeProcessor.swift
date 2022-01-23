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

struct WorkoutActiveTimeSegment {
    let startDate: Date
    let endDate: Date
}

class WorkoutActiveTimeProcessor {
    func getActiveTimeSegmentsForWorkout(
        startDate: Date,
        endDate: Date?,
        workoutEvents: [WorkoutEvent]
    ) -> [WorkoutActiveTimeSegment] {
        let endDate: Date = endDate != nil ? endDate! : Date()
        var result = [WorkoutActiveTimeSegment]()
        var prevStart: Date? = startDate
        for event in workoutEvents {
            if event.type == .pauseWorkout {
                if let prevStartUnwrapped = prevStart {
                    let segment = WorkoutActiveTimeSegment(startDate: prevStartUnwrapped, endDate: event.date)
                    result.append(segment)
                    prevStart = nil
                }
            } else if event.type == .resumeWorkout {
                prevStart = event.date
            }
        }
        if let prevStart = prevStart {
            result.append(WorkoutActiveTimeSegment(startDate: prevStart, endDate: endDate))
        }
        return result
    }
}
