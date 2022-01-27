//
//  ZoneStatisticsTest.swift
//  HeartZonesTests
//
//  Created by Michal Manak - personal on 23/01/2022.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class ZoneStatisticsTest: XCTestCase {
    func testZoneStatisticsRoundingUpAndDown() {
        let sut = ZoneStatistics(timeInZones: [:], percentagesInZones: [0: 0.66666, 1: 0.33333], totalTime: 0)
        let result = sut.getSmoothedPercentagesInZones()
        XCTAssertEqual(result[0], 67)
        XCTAssertEqual(result[1], 33)
    }

    func testZoneStatisticsSimpleDownAndUp() {
        let sut = ZoneStatistics(timeInZones: [:], percentagesInZones: [0: 0.5111, 1: 0.4899], totalTime: 0)
        let result = sut.getSmoothedPercentagesInZones()
        XCTAssertEqual(result[0], 51)
        XCTAssertEqual(result[1], 49)
    }

    func testZoneStatisticsPotentialOverflow() {
        let sut = ZoneStatistics(timeInZones: [:], percentagesInZones: [0: 0.5211, 1: 0.4899], totalTime: 0)
        let result = sut.getSmoothedPercentagesInZones()
        XCTAssertEqual(result[0], 52)
        XCTAssertEqual(result[1], 48)
    }
}
