//
//  AuthorizableFake.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 24/07/2021.
//

import Foundation
import Combine
@testable import HeartZones_WatchKit_Extension

class AuthorizableFake: Authorizable {
    var requestCalledCount = 0
    private var successIn: Int
    private var fulfill: Bool
    
    init(successIn: Int, fulfill: Bool = true) {
        self.successIn = successIn
        self.fulfill = fulfill
    }
    
    func requestAuthorization() -> Future<Bool, Never> {
        requestCalledCount += 1
        return Future<Bool, Never>({ promise in
            if self.fulfill {
                if self.requestCalledCount >= self.successIn {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        })
    }
}
