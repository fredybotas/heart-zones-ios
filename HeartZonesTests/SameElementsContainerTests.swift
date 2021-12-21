//
//  SameElementsContainerTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 28/07/2021.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class SameElementsContainerTests: XCTestCase {
    var sut: SameElementsContainer<Int>!

    override func setUp() {
        sut = SameElementsContainer<Int>()
    }

    func testInsert() {
        sut.RefreshAndInsert(element: 1)

        XCTAssertEqual(sut.count, 1)
    }

    func testRemoveAll() {
        sut.RefreshAndInsert(element: 1)
        sut.RefreshAndInsert(element: 1)
        sut.removeAll()
        XCTAssertEqual(sut.count, 0)
    }

    func testInsertOtherElement() {
        sut.RefreshAndInsert(element: 1)
        sut.RefreshAndInsert(element: 1)

        sut.RefreshAndInsert(element: 2)
        XCTAssertEqual(sut.count, 1)
    }

    func testInsertSameElements() {
        sut.RefreshAndInsert(element: 1)
        sut.RefreshAndInsert(element: 1)
        sut.RefreshAndInsert(element: 1)

        XCTAssertEqual(sut.count, 3)
    }
}
