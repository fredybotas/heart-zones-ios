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
        container = DistanceContainer(lapSize: 400)
    }

    func testInsert() {
        container.insert(distance: 10.0, timeInterval: 2.0)
        container.insert(distance: 10.0, timeInterval: 2.0)
        container.insert(distance: 10.0, timeInterval: 2.0)
   
        XCTAssertNotNil(container.getAverageSpeed())
    }

    func testCalculationInOneLap() {
        container.insert(distance: 5.0, timeInterval: 2.0)
        container.insert(distance: 10.0, timeInterval: 2.0)
        container.insert(distance: 15.0, timeInterval: 2.0)
        
        guard let value = container.getAverageSpeed()?.value else { return }
        XCTAssertEqual(value, Measurement.init(value: 5.0, unit: UnitSpeed.metersPerSecond).value, accuracy: 0.1)
    }

    func testCalculationLapFinished() {
        container.insert(distance: 200, timeInterval: 2.0)
        container.insert(distance: 202, timeInterval: 2.0)
        
        guard let value = container.getAverageSpeed()?.value else { return }
        XCTAssertEqual(value, Measurement.init(value: 402.0 / 4.0, unit: UnitSpeed.metersPerSecond).value, accuracy: 0.1)
    }

    func testCalculationWhenLapReset() {
        container.insert(distance: 402, timeInterval: 4.0)
        container.insert(distance: 10, timeInterval: 4.0)
        
        guard let value = container.getAverageSpeed()?.value else { return }
        XCTAssertEqual(value, Measurement.init(value: 10.0 / 4.0, unit: UnitSpeed.metersPerSecond).value, accuracy: 0.1)
    }
    
}
