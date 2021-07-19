//
//  BpmContainerTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 01/07/2021.
//

import XCTest
@testable import HeartZones_WatchKit_Extension

class BpmContainerTests: XCTestCase {
    var container: BpmContainer!

    override func setUp() {
        container = BpmContainer(size: 3)
    }

    func testInsert() throws {
        container.insert(bpm: 1)
        container.insert(bpm: 3)
        container.insert(bpm: 5)
        
        XCTAssertNotNil(container.getActualBpm())
    }

    func testCalculation() throws {
        container.insert(bpm: 5)
        container.insert(bpm: 10)
        container.insert(bpm: 15)
        
        XCTAssertEqual(container.getActualBpm(), 10)
    }
}
