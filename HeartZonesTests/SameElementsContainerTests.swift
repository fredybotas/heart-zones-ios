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
        self.sut = SameElementsContainer<Int>()
    }
       
    func testInsert() {
        self.sut.RefreshAndInsert(element: 1)
        
        XCTAssertEqual(self.sut.count, 1)
    }
    
    func testRemoveAll() {
        self.sut.RefreshAndInsert(element: 1)
        self.sut.RefreshAndInsert(element: 1)
        self.sut.removeAll()
        XCTAssertEqual(self.sut.count, 0)
    }
    
    func testInsertOtherElement() {
        self.sut.RefreshAndInsert(element: 1)
        self.sut.RefreshAndInsert(element: 1)
        
        self.sut.RefreshAndInsert(element: 2)
        XCTAssertEqual(self.sut.count, 1)
    }
    
    func testInsertSameElements() {
        self.sut.RefreshAndInsert(element: 1)
        self.sut.RefreshAndInsert(element: 1)
        self.sut.RefreshAndInsert(element: 1)
        
        XCTAssertEqual(self.sut.count, 3)
    }
}
