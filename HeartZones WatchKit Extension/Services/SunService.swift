//
//  SunService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 13/07/2021.
//

import Combine
import CoreLocation
import Foundation
import Solar

protocol ISunService {
    func getSunset() -> Future<Date, Never>
}

private let kSunsetShift: TimeInterval = -300 // Make sunset 5min earlier as it seems to be more reasonable

class SunService: ISunService {
    private let locationManager: OnDemandLocationFetcher
    private var cancellables = Set<AnyCancellable>()

    init(locationManager: OnDemandLocationFetcher) {
        self.locationManager = locationManager
    }

    func getSunset() -> Future<Date, Never> {
        return Future { promise in
            self.locationManager
                .getLocation()
                .map { location in
                    let solar = Solar(for: Date(), coordinate: location.coordinate)
                    // TODO: Handle error
                    guard let sunset = solar?.civilSunset else { return Date() }
                    return sunset.addingTimeInterval(kSunsetShift)
                }
                .sink {
                    promise(.success($0))
                }
                .store(in: &self.cancellables)
        }
    }
}
