//
//  SunService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 13/07/2021.
//

import Foundation
import CoreLocation
import Solar
import Combine

protocol ISunService {
    func getSunset() -> Future<Date, Never>
}

class SunService: ISunService {

    private let locationManager: LocationManager
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func getSunset() -> Future<Date, Never> {
        return Future({ promise in
        })
    }
}

