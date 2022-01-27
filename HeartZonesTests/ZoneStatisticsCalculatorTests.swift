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
        let result = sut.calculateStatisticsFor(segments: [
            BpmEntrySegment(startDate: startDate,
                            endDate: endDate, entries: [
                                BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm),
                                         timestamp: startDate.addingTimeInterval(2).timeIntervalSince1970),
                                BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm),
                                         timestamp: startDate.addingTimeInterval(4).timeIntervalSince1970)
                            ])
        ])

        XCTAssertEqual(result.timeInZones[zone.id], endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        XCTAssertEqual(result.percentagesInZones[zone.id], 1)
    }

    func testGetStatisticsForOneSegmentInDifferentZones() {
        let startDate = Date()
        let endDate = Date().addingTimeInterval(10)
        let zone1 = settingsService.selectedHeartZoneSetting.zones[0]
        let zone2 = settingsService.selectedHeartZoneSetting.zones[1]
        let result = sut.calculateStatisticsFor(segments: [
            BpmEntrySegment(startDate: startDate,
                            endDate: endDate, entries: [
                                BpmEntry(value: zone1.sampleBpm(maximumBpm: settingsService.maximumBpm),
                                         timestamp: startDate.addingTimeInterval(2).timeIntervalSince1970),
                                BpmEntry(value: zone2.sampleBpm(maximumBpm: settingsService.maximumBpm),
                                         timestamp: startDate.addingTimeInterval(4).timeIntervalSince1970)
                            ])
        ])
        XCTAssertEqual(result.timeInZones[zone1.id], 2)
        XCTAssertEqual(result.timeInZones[zone2.id], 8)
        XCTAssertEqual(result.percentagesInZones[zone1.id], 0.2)
        XCTAssertEqual(result.percentagesInZones[zone2.id], 0.8)
    }

    func testGetStatisticsForTwoSegmentInSameZone() {
        let startDateSegment1 = Date().addingTimeInterval(-10)
        let endDateSegment1 = Date()
        let startDateSegment2 = endDateSegment1.addingTimeInterval(2)
        let endDateSegment2 = startDateSegment2.addingTimeInterval(10)

        let zone = settingsService.selectedHeartZoneSetting.zones[0]
        let result = sut.calculateStatisticsFor(segments: [
            BpmEntrySegment(startDate: startDateSegment1, endDate: endDateSegment1, entries: [
                BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment1.addingTimeInterval(2).timeIntervalSince1970),
                BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment1.addingTimeInterval(4).timeIntervalSince1970)
            ]), BpmEntrySegment(startDate: startDateSegment2, endDate: endDateSegment2, entries: [
                BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment2.addingTimeInterval(2).timeIntervalSince1970),
                BpmEntry(value: zone.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment2.addingTimeInterval(4).timeIntervalSince1970)
            ])
        ])

        XCTAssertEqual(result.timeInZones[zone.id],
                       (endDateSegment1.timeIntervalSince1970 - startDateSegment1.timeIntervalSince1970) +
                           (endDateSegment2.timeIntervalSince1970 - startDateSegment2.timeIntervalSince1970))
        XCTAssertEqual(result.percentagesInZones[zone.id], 1)
    }

    func testGetStatisticsForTwoSegmentInDifferentZones() {
        let startDateSegment1 = Date().addingTimeInterval(-10)
        let endDateSegment1 = Date()
        let startDateSegment2 = endDateSegment1.addingTimeInterval(2)
        let endDateSegment2 = startDateSegment2.addingTimeInterval(10)

        let zone1 = settingsService.selectedHeartZoneSetting.zones[0]
        let zone2 = settingsService.selectedHeartZoneSetting.zones[1]

        let result = sut.calculateStatisticsFor(segments: [
            BpmEntrySegment(startDate: startDateSegment1, endDate: endDateSegment1, entries: [
                BpmEntry(value: zone1.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment1.addingTimeInterval(2).timeIntervalSince1970),
                BpmEntry(value: zone1.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment1.addingTimeInterval(4).timeIntervalSince1970)
            ]), BpmEntrySegment(startDate: startDateSegment2, endDate: endDateSegment2, entries: [
                BpmEntry(value: zone2.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment2.addingTimeInterval(2).timeIntervalSince1970),
                BpmEntry(value: zone2.sampleBpm(maximumBpm: settingsService.maximumBpm),
                         timestamp: startDateSegment2.addingTimeInterval(4).timeIntervalSince1970)
            ])
        ])

        XCTAssertEqual(result.timeInZones[zone1.id],
                       endDateSegment1.timeIntervalSince1970 - startDateSegment1.timeIntervalSince1970)
        XCTAssertEqual(result.timeInZones[zone2.id],
                       endDateSegment2.timeIntervalSince1970 - startDateSegment2.timeIntervalSince1970)

        XCTAssertEqual(result.percentagesInZones[zone1.id], 0.5)
        XCTAssertEqual(result.percentagesInZones[zone2.id], 0.5)
    }
}
