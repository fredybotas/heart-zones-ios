//
//  DistanceContainerTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 19/07/2021.
//

import XCTest
@testable import HeartZones_WatchKit_Extension

class DistanceContainerTests: XCTestCase {
    var container: DistanceContainer!

    override func setUp() {
        container = DistanceContainer(size: 3)
    }

    func testInsert() {
        container.insert(distance: 10.0, timeInterval: 2.0)
        container.insert(distance: 10.0, timeInterval: 2.0)
        container.insert(distance: 10.0, timeInterval: 2.0)
   
        XCTAssertNotNil(container.getAverageSpeed())
    }

    func testCalculation() throws {
        container.insert(distance: 5.0, timeInterval: 2.0)
        container.insert(distance: 10.0, timeInterval: 2.0)
        container.insert(distance: 15.0, timeInterval: 2.0)
        
        guard let value = container.getAverageSpeed()?.value else { return }
        XCTAssertEqual(value, Measurement.init(value: 5.0, unit: UnitSpeed.metersPerSecond).value, accuracy: 0.1)
    }
}
