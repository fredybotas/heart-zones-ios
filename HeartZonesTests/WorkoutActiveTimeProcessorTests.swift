//
//  WorkoutActiveTimeProcessorTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak - personal on 18/01/2022.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class WorkoutActiveTimeProcessorTests: XCTestCase {
    var sut: WorkoutActiveTimeProcessor!

    override func setUp() {
        sut = WorkoutActiveTimeProcessor()
    }

    func testGetActiveTimeForWorkoutWithoutPauses() {
        let startDate = Date().addingTimeInterval(-10)
        let endDate = Date()
        let result = sut.getActiveTimeSegmentsForWorkout(
            startDate: startDate,
            endDate: endDate, workoutEvents: []
        )
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].0, startDate)
        XCTAssertEqual(result[0].1, endDate)
    }

    func testGetActiveTimeForWorkoutWithOnePauseAndStart() {
        let referenceDate = Date()
        let startDate = referenceDate.addingTimeInterval(-10)
        let endDate = referenceDate

        let result = sut.getActiveTimeSegmentsForWorkout(
            startDate: startDate,
            endDate: endDate, workoutEvents: [
                WorkoutEvent(type: .pauseWorkout, date: referenceDate.addingTimeInterval(-6)),
                WorkoutEvent(type: .resumeWorkout, date: referenceDate.addingTimeInterval(-4))
            ]
        )

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].0, startDate)
        XCTAssertEqual(result[0].1, referenceDate.addingTimeInterval(-6))
        XCTAssertEqual(result[1].0, referenceDate.addingTimeInterval(-4))
        XCTAssertEqual(result[1].1, endDate)
    }

    func testGetActiveTimeForWorkoutWithoutEnd() {
        let referenceDate = Date()
        let endDate = referenceDate
        let startDate = referenceDate.addingTimeInterval(-10)

        let result = sut.getActiveTimeSegmentsForWorkout(
            startDate: startDate, endDate: nil, workoutEvents: []
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].0, startDate)
        XCTAssertEqual(result[0].1.timeIntervalSince1970, endDate.timeIntervalSince1970, accuracy: 2)
    }

    func testGetActiveTimeForWorkoutWithOnePause() {
        let referenceDate = Date()
        let startDate = referenceDate.addingTimeInterval(-10)

        let result = sut.getActiveTimeSegmentsForWorkout(
            startDate: Date().addingTimeInterval(-10),
            endDate: Date(), workoutEvents: [
                WorkoutEvent(type: .pauseWorkout, date: referenceDate.addingTimeInterval(-6)),
            ]
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].0, startDate)
        XCTAssertEqual(result[0].1, referenceDate.addingTimeInterval(-6))

    }

    func testGetActiveTimeForWorkoutWithMultiplePauseAndStart() {
        let referenceDate = Date()
        let startDate = referenceDate.addingTimeInterval(-10)
        let endDate = referenceDate

        let result = sut.getActiveTimeSegmentsForWorkout(
            startDate: startDate,
            endDate: Date(), workoutEvents: [
                WorkoutEvent(type: .pauseWorkout, date: referenceDate.addingTimeInterval(-8)),
                WorkoutEvent(type: .resumeWorkout, date: referenceDate.addingTimeInterval(-6)),
                WorkoutEvent(type: .pauseWorkout, date: referenceDate.addingTimeInterval(-4)),
                WorkoutEvent(type: .resumeWorkout, date: referenceDate.addingTimeInterval(-2))
            ]
        )

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].0, startDate)
        XCTAssertEqual(result[0].1, referenceDate.addingTimeInterval(-8))
        XCTAssertEqual(result[1].0, referenceDate.addingTimeInterval(-6))
        XCTAssertEqual(result[1].1, referenceDate.addingTimeInterval(-4))
        XCTAssertEqual(result[2].0, referenceDate.addingTimeInterval(-2))
        XCTAssertEqual(result[2].1, endDate)
    }
}
