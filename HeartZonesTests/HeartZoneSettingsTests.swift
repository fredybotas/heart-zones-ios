//
//  HeartZoneSettingsTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 19/07/2021.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class HeartZoneSettingsTests: XCTestCase {
    var sut: HeartZonesSetting!

    let maxBpm = 190
    
    override func setUp() {
        self.sut = HeartZonesSetting.getDefaultHeartZonesSetting()
    }
    
    func getBpmSampleFromHeartZone(zone: HeartZone) -> Int {
        return zone.getBpmRange(maxBpm: maxBpm).lowerBound + 1
    }
    
    func testEvaluateWithoutAnyZone() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: nil, bpm: getBpmSampleFromHeartZone(zone: self.sut.zones[1]), maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .undefined)
        XCTAssertNotNil(zone)
    }
    
    func testEvaluationStayInZone() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[0], bpm: getBpmSampleFromHeartZone(zone: self.sut.zones[0]), maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .stay)
        XCTAssertNil(zone)
    }
    
    func testEvaluationChangeZoneUp() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[0], bpm: getBpmSampleFromHeartZone(zone: self.sut.zones[1]), maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .up)
        XCTAssertEqual(zone, self.sut.zones[1])
    }
    
    func testEvaluationChangeZoneDown() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[1], bpm: getBpmSampleFromHeartZone(zone: self.sut.zones[0]), maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .down)
        XCTAssertEqual(zone, self.sut.zones[0])
    }
    
    func testEvaluationSkipOneZone() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[0], bpm: getBpmSampleFromHeartZone(zone: self.sut.zones[2]), maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .up)
        XCTAssertEqual(zone, self.sut.zones[2])
    }
    
    func testEvaluationSameZone() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[0], bpm: getBpmSampleFromHeartZone(zone: self.sut.zones[0]), maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .stay)
        XCTAssertNil(zone)
    }
    
    func testEvaluationBpmLowerThanAnyZone() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[0], bpm: -20, maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .undefined)
        XCTAssertEqual(zone, self.sut.zones[0])
    }
    
    func testEvaluationBpmHigherThanAnyZone() {
        let (movement, zone) = self.sut.evaluateBpmChange(currentZone: self.sut.zones[0], bpm: 300, maxBpm: maxBpm)
        
        XCTAssertEqual(movement, .undefined)
        XCTAssertEqual(zone, self.sut.zones[3])
    }
    
    
}
