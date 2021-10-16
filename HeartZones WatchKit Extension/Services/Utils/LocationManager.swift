//
//  LocationManager.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 09/07/2021.
//

import Foundation
import CoreLocation
import Combine

protocol OnDemandLocationFetcher {
    func getLocation() -> Future<CLLocation, Never>
}

protocol WorkoutLocationFetcher {
    func getWorkoutLocationUpdatesPublisher() -> AnyPublisher<CLLocation, Never>
    func startWorkoutLocationUpdates()
    func stopWorkoutLocationUpdates()
}

class LocationManager: NSObject, WorkoutLocationFetcher, OnDemandLocationFetcher, CLLocationManagerDelegate, Authorizable {
    
    let manager = CLLocationManager()
        
    var workoutLocationPublisher = PassthroughSubject<CLLocation, Never>()
    var startsRequested = 0
    
    var locationRequests = [(Result<CLLocation, Never>) -> Void]()
    
    
    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        //TODO: Handle authorization correctly. Mainly errors when location was not authorized
    }
    
    func getLocation() -> Future<CLLocation, Never> {
        self.manager.requestLocation()
        // TODO: Handle error when location cannot be acquired in reasonable time: CLError.Code.locationUnknown
        return Future<CLLocation, Never>({ [weak self] promise in
            self?.locationRequests.append(promise)
        })
    }
    
    func getWorkoutLocationUpdatesPublisher() -> AnyPublisher<CLLocation, Never> {
        return workoutLocationPublisher
            .filter({ location in
                // TODO: Add reasonable filter for vertical accuracy
                return location.horizontalAccuracy < 30 && location.horizontalAccuracy > 0
            })
            .throttle(for: 3, scheduler: RunLoop.main, latest: true)
            .eraseToAnyPublisher()
    }
    
    func startWorkoutLocationUpdates() {
        startsRequested += 1
        manager.startUpdatingLocation()
    }
    
    func stopWorkoutLocationUpdates() {
        startsRequested -= 1
        if startsRequested > 0 {
            return
        }
        manager.stopUpdatingLocation()
        workoutLocationPublisher.send(completion: .finished)
        workoutLocationPublisher = PassthroughSubject<CLLocation, Never>()
    }
    
    func requestAuthorization() -> Future<Bool, Never> {
        manager.requestWhenInUseAuthorization()
        // TODO: Rework to return status correctly when watchos7 available
        return Future<Bool, Never>({ promise in
            promise(.success(true))
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach({ workoutLocationPublisher.send($0) })
        
        guard let lastLocation = locations.last else { return }
        
        while !locationRequests.isEmpty {
            guard let request = locationRequests.popLast() else { continue }
            request(.success(lastLocation))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
