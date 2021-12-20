//
//  HealthKitServiceMock.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 24/07/2021.
//

import Foundation
import HealthKit
import Combine

@testable import HeartZones_WatchKit_Extension

class HealthKitServiceMock: IHealthKitService {
    func getBpmData(startDate: NSDate) -> Future<[BpmEntry], Never> {
        return Future.init({ promise in
            promise(.success([]))
        })
    }
    
    var getAgeCalledCount = 0
    
    var age: Int? {
        getAgeCalledCount += 1
        return 50
    }
    
    var healthStore = HKHealthStore()
    
    func authorizeHealthKitAccess(completion: @escaping (Bool, HKError.Code?) -> Void) {}
}
