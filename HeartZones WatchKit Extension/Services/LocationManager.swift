//
//  LocationManager.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 09/07/2021.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
        
    let manager = CLLocationManager()
        
    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    
    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func getWorkoutLocationUpdatesPublisher() -> AnyPublisher<CLLocation, Never> {
        // TODO: Fix to not force unwrap
        return locationPublisher
            .filter({ location in
                return location.horizontalAccuracy < 30
            })
            .throttle(for: 3, scheduler: RunLoop.main, latest: true)
            .eraseToAnyPublisher()
    }
    
    func startWorkoutLocationUpdates() {
        manager.startUpdatingLocation()
    }
    
    func stopWorkoutLocationUpdates() {
        manager.stopUpdatingLocation()
        locationPublisher.send(completion: .finished)
        locationPublisher = PassthroughSubject<CLLocation, Never>()
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach({ locationPublisher.send($0) })
    }
}
