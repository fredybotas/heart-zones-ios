//
//  WorkoutReadOnlyService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 01/02/2022.
//

import Foundation

class WorkoutReadOnlyService: WorkoutControlsProtocol {
    private var workoutStartedAt: Date?
    private let healthKitService: FetchBpmDataProtocol
    private let zoneStatisticsCalculator: IZoneStaticticsCalculator

    init(healthKitService: FetchBpmDataProtocol, zoneStatisticsCalculator: IZoneStaticticsCalculator) {
        self.healthKitService = healthKitService
        self.zoneStatisticsCalculator = zoneStatisticsCalculator
        workoutStartedAt = Date()
    }

    func setWorkoutStarted() {
        workoutStartedAt = Date()
    }

    func getActiveWorkoutStartDate() -> Date? {
        return workoutStartedAt
    }

    func getActiveWorkoutZoneStatistics() -> ZoneStatistics? {
        guard let workoutStartedAt = workoutStartedAt else { return nil }

        let segment = BpmEntrySegment(startDate: workoutStartedAt, endDate: Date())
        segment.fillEntries(healthKitService: healthKitService)
        return zoneStatisticsCalculator.calculateStatisticsFor(segments: [
            segment
        ])
    }
}
