//
//  HealthKitServiceMock.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 24/07/2021.
//

import Combine
import Foundation
import HealthKit

@testable import HeartZones_WatchKit_Extension

class HealthKitServiceMock: IHealthKitService {
    func getBpmData(startDate _: NSDate) -> Future<[BpmEntry], Never> {
        return Future { promise in
            promise(.success([]))
        }
    }

    var getAgeCalledCount = 0

    var age: Int? {
        getAgeCalledCount += 1
        return 50
    }

    var healthStore = HKHealthStore()

    func authorizeHealthKitAccess(completion _: @escaping (Bool, HKError.Code?) -> Void) {}
}
