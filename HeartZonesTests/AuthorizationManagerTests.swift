//
//  AuthorizationManagerTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 24/07/2021.
//

import Combine
import XCTest

@testable import HeartZones_WatchKit_Extension

class AuthorizationManagerTests: XCTestCase {
    func testAuthorizationCalledOnMoreAuthorizables() {
        let authorizable1 = AuthorizableFake(successIn: 1)
        let authorizable2 = AuthorizableFake(successIn: 1)

        let sut = AuthorizationManager(authorizables: [authorizable1, authorizable2])
        sut.startAuthorizationChain()
        XCTAssertEqual(authorizable1.requestCalledCount, 1)
        XCTAssertEqual(authorizable2.requestCalledCount, 1)
    }

    func testAuthorizationRetry() {
        let authorizable1 = AuthorizableFake(successIn: 2)
        let sut = AuthorizationManager(authorizables: [authorizable1])
        sut.startAuthorizationChain()
        XCTAssertEqual(authorizable1.requestCalledCount, 2)
    }

    func testMultipleAuthorizationCalled() {
        let authorizable1 = AuthorizableFake(successIn: 1)

        let sut = AuthorizationManager(authorizables: [authorizable1])
        sut.startAuthorizationChain()
        sut.startAuthorizationChain()

        XCTAssertEqual(authorizable1.requestCalledCount, 2)
    }

    func testMultipleAuthorizationCalledWhenFirstIsNotFinishedYet() {
        let authorizable1 = AuthorizableFake(successIn: 1, fulfill: false)

        let sut = AuthorizationManager(authorizables: [authorizable1])
        sut.startAuthorizationChain()
        sut.startAuthorizationChain()

        XCTAssertEqual(authorizable1.requestCalledCount, 1)
    }
}
