//
//  ZoneStatisticsCalculatorTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak - personal on 23/01/2022.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class ZoneStatisticsCalculatorTests: XCTestCase {
    var sut: ZoneStatisticsCalculator!
    var settingsService: ISettingsService!

    override func setUp() {
        settingsService = SettingsServiceFake()
        sut = ZoneStatisticsCalculator(settingsService: settingsService)
    }

    func testGetStatisticsForOneSegmentInSameZone() {
        let startDate = Date().addingTimeInterval(-10)
        let endDate = Date()
        let zone = settingsService.selectedHeartZoneSetting.zones[0]
        let result = sut.calculateStatisticsFor(segments: [BpmEntrySegment(startDate: startDate, endDate: endDate, entries: [
            BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm), timestamp: startDate.addingTimeInterval(2).timeIntervalSince1970),
            BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm), timestamp: startDate.addingTimeInterval(4).timeIntervalSince1970)
        ])])

        XCTAssertEqual(result.timeInZones[zone.id], endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        XCTAssertEqual(result.percentagesInZones[zone.id], 100)
    }

    func testGetStatisticsForOneSegmentInDifferentZones() {
        let startDate = Date()
        let endDate = Date().addingTimeInterval(10)
        let zone1 = settingsService.selectedHeartZoneSetting.zones[0]
        let zone2 = settingsService.selectedHeartZoneSetting.zones[1]
        let result = sut.calculateStatisticsFor(segments: [BpmEntrySegment(startDate: startDate, endDate: endDate, entries: [
            BpmEntry(value: zone1.sampleBpm(maximumBpm: settingsService.maximumBpm), timestamp: startDate.addingTimeInterval(2).timeIntervalSince1970),
            BpmEntry(value: zone2.sampleBpm(maximumBpm: settingsService.maximumBpm), timestamp: startDate.addingTimeInterval(4).timeIntervalSince1970)
        ])])

        XCTAssertEqual(result.timeInZones[zone1.id], 2)
        XCTAssertEqual(result.timeInZones[zone2.id], 8)
        XCTAssertEqual(result.percentagesInZones[zone1.id], 20)
        XCTAssertEqual(result.percentagesInZones[zone2.id], 80)
    }
}
