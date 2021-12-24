//
//  BpmSegmentProcessorTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak - personal on 23/12/2021.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class BpmSegmentProcessorTests: XCTestCase {
    var sut: BpmSegmentProcessor!
    var settingsServiceFake: SettingsServiceFake!

    override func setUp() {
        settingsServiceFake = SettingsServiceFake()
        sut = BpmSegmentProcessor(settingsService: settingsServiceFake)
    }

    func testInterpolationBasic() {
        let lower = BpmEntry(value: 100, timestamp: 100)
        let upper = BpmEntry(value: 120, timestamp: 200)
        XCTAssertEqual(
            BpmSegmentProcessor.getInterpolatedTimestamp(
                lower: lower,
                upper: upper,
                bpmToInterpolate: 110
            ), 150
        )
    }

    func testInterpolationAdvanced() {
        let lower = BpmEntry(value: 100, timestamp: 1)
        let upper = BpmEntry(value: 120, timestamp: 2)
        XCTAssertEqual(
            BpmSegmentProcessor.getInterpolatedTimestamp(
                lower: lower,
                upper: upper,
                bpmToInterpolate: 110
            ), 1.5
        )
    }

    func testPrepareSegmentBasic() {
        let entries = [
            BpmEntry(value: 100, timestamp: 100),
            BpmEntry(value: 100, timestamp: 100),
            BpmEntry(value: 100, timestamp: 100)
        ]
        let segment = sut.processBpmEntries(bpmEntries: entries)
        XCTAssertEqual(segment.count, 1)
        let segmentColor = settingsServiceFake
            .selectedHeartZoneSetting
            .getZoneForBpm(bpm: 100, maxBpm: settingsServiceFake.maximumBpm)
            .color
        let expectedSegment = BpmSegment(color: segmentColor, bpms: entries)
        XCTAssertEqual(segment[0], expectedSegment)
    }

    func testPrepareEmptySegment() {
        let segment = sut.processBpmEntries(bpmEntries: [])
        XCTAssert(segment.isEmpty)
    }

    func testPrepareSegmentWithOneEntry() {
        let segment = sut.processBpmEntries(bpmEntries: [BpmEntry(value: 100, timestamp: 100)])
        XCTAssertEqual(segment.count, 1)
        let segmentColor = settingsServiceFake
            .selectedHeartZoneSetting
            .getZoneForBpm(bpm: 100, maxBpm: settingsServiceFake.maximumBpm)
            .color
        XCTAssertEqual(segment[0], BpmSegment(color: segmentColor, bpms: [BpmEntry(value: 100, timestamp: 100)]))
    }

    func testPrepareSegmentWithOneZoneTransmission() {
        let entries = [
            BpmEntry(value: 100, timestamp: 100),
            BpmEntry(value: 101, timestamp: 101),
            BpmEntry(value: 102, timestamp: 102),
            BpmEntry(value: 120, timestamp: 120),
            BpmEntry(value: 121, timestamp: 121),
            BpmEntry(value: 122, timestamp: 122)
        ]

        let segment = sut.processBpmEntries(bpmEntries: entries)
        print(segment)
        XCTAssertEqual(segment.count, 2)
    }

    func testPrepareSegmentWithTwoZoneTransmission() {
        let entries = [
            BpmEntry(value: 100, timestamp: 100),
            BpmEntry(value: 101, timestamp: 101),
            BpmEntry(value: 102, timestamp: 102),
            BpmEntry(value: 120, timestamp: 120),
            BpmEntry(value: 121, timestamp: 121),
            BpmEntry(value: 122, timestamp: 122),
            BpmEntry(value: 150, timestamp: 150),
            BpmEntry(value: 151, timestamp: 151),
            BpmEntry(value: 152, timestamp: 152)
        ]

        let segment = sut.processBpmEntries(bpmEntries: entries)
        print(segment)
        XCTAssertEqual(segment.count, 3)
    }

    func testPrepareSegmentWithOneZoneTransmissionAndOneMarginSegment() {
        let entries = [
            BpmEntry(value: 100, timestamp: 100),
            BpmEntry(value: 101, timestamp: 101),
            BpmEntry(value: 102, timestamp: 102),
            BpmEntry(value: 150, timestamp: 150),
            BpmEntry(value: 151, timestamp: 151),
            BpmEntry(value: 152, timestamp: 152)
        ]

        let segment = sut.processBpmEntries(bpmEntries: entries)
        XCTAssertEqual(segment.count, 3)
    }

    func testPrepareSegmentWithOneZoneTransmissionAndOneMarginSegmentReversed() {
        let entries = [
            BpmEntry(value: 152, timestamp: 100),
            BpmEntry(value: 151, timestamp: 101),
            BpmEntry(value: 150, timestamp: 102),
            BpmEntry(value: 102, timestamp: 150),
            BpmEntry(value: 101, timestamp: 151),
            BpmEntry(value: 100, timestamp: 152)
        ]

        let segment = sut.processBpmEntries(bpmEntries: entries)
        XCTAssertEqual(segment.count, 3)
    }

    func testPrepareSegmentWithOneZoneTransmissionReversed() {
        let entries = [
            BpmEntry(value: 122, timestamp: 100),
            BpmEntry(value: 121, timestamp: 101),
            BpmEntry(value: 120, timestamp: 102),
            BpmEntry(value: 102, timestamp: 120),
            BpmEntry(value: 101, timestamp: 121),
            BpmEntry(value: 100, timestamp: 122)
        ]

        let segment = sut.processBpmEntries(bpmEntries: entries)
        let upperZone = settingsServiceFake.selectedHeartZoneSetting.getZoneForBpm(
            bpm: 122,
            maxBpm: settingsServiceFake.maximumBpm
        )
        let lowerZone = settingsServiceFake.selectedHeartZoneSetting.getZoneForBpm(
            bpm: 102,
            maxBpm: settingsServiceFake.maximumBpm
        )
        let expectedSegments = [
            BpmSegment(
                color: upperZone.color,
                bpms: [entries[0],
                       entries[1],
                       entries[2],
                       BpmEntry(value: upperZone.getZoneMinBpm(maxBpm: settingsServiceFake.maximumBpm), timestamp: 105)]
            ),
            BpmSegment(
                color: lowerZone.color,
                bpms: [
                    BpmEntry(value: lowerZone.getZoneMaxBpm(maxBpm: settingsServiceFake.maximumBpm), timestamp: 105),
                    entries[3],
                    entries[4],
                    entries[5]
                ]
            )
        ]
        XCTAssertEqual(segment.count, 2)
        XCTAssertEqual(segment, expectedSegments)
    }
}
