//
//  DistanceShowingStrategy.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/08/2021.
//

import Foundation

protocol IDistanceShowingStrategy {
    func getDistanceValue(_ data: DistanceData) -> String
    func getDistanceUnit(_ data: DistanceData) -> String
    
    func getCurrentPace(_ data: DistanceData) -> String
    func getAveragePace(_ data: DistanceData) -> String
}

class MetricDistanceWithPaceShowingStrategy: IDistanceShowingStrategy {
    let distanceFormatter = MeasurementFormatter()
    
    init() {
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.unitStyle = .medium
    }
    
    func getDistanceValue(_ data: DistanceData) -> String {
//        // TODO: Change to optional without forcing
//        var unit: UnitLength!
//        if data.distance < Measurement.init(value: 1, unit: UnitLength.kilometers) {
//            self?.distanceFormatter.numberFormatter.maximumFractionDigits = 0
//            unit = UnitLength.meters
//        } else if data.distance >= Measurement.init(value: 100, unit: UnitLength.kilometers) {
//            self?.distanceFormatter.numberFormatter.maximumFractionDigits = 0
//            unit = UnitLength.kilometers
//        } else {
//            self?.distanceFormatter.numberFormatter.maximumFractionDigits = 1
//            self?.distanceFormatter.numberFormatter.minimumFractionDigits = 1
//            unit = UnitLength.kilometers
//        }
//        let distanceString = self?.distanceFormatter.numberFormatter.string(from: NSNumber(value: data.distance.converted(to: unit).value))
//        // TODO: Fix this hack
//        let unitString = self?.distanceFormatter.string(from: data.distance.converted(to: unit)).split(separator: " ")[1]
//
//        guard let distanceString = distanceString else { return }
//        guard let unitString = unitString else { return }
//
//        self?.distance = distanceString
//        self?.distanceUnit = unitString.uppercased()
        return ""
    }
    
    func getDistanceUnit(_ data: DistanceData) -> String {
        return ""
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMetricPaceString()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMetricPaceString()
    }
}

class MilleageDistanceWithPaceShowingStrategy: IDistanceShowingStrategy {
    func getDistanceValue(_ data: DistanceData) -> String {
        return ""
    }
    
    func getDistanceUnit(_ data: DistanceData) -> String {
        return ""
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMilleagePaceString()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMilleagePaceString()
    }
    

}

class MetricDistanceWithSpeedShowingStrategy: IDistanceShowingStrategy {
    func getDistanceValue(_ data: DistanceData) -> String {
        return ""
    }
    
    func getDistanceUnit(_ data: DistanceData) -> String {
        return ""
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMetricSpeedString()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMetricSpeedString()
    }
    

}

class MilleageDistanceWithSpeedShowingStrategy: IDistanceShowingStrategy {
    func getDistanceValue(_ data: DistanceData) -> String {
        return ""
    }
    
    func getDistanceUnit(_ data: DistanceData) -> String {
        return ""
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMilleageSpeedString()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMilleageSpeedString()
    }
}

fileprivate extension Measurement where UnitType == UnitSpeed {
    func toMetricPaceString() -> String {
        let metresPerSec = self.converted(to: UnitSpeed.metersPerSecond).value
        if metresPerSec == 0 {
            return "--'--''"
        }
        let kilometresPerSec = metresPerSec / 1000
        let secsForKilometer = Int.init(1 / kilometresPerSec)
        return String(format: "%0.2d'%0.2d''", secsForKilometer / 60, secsForKilometer % 60)
    }
    
    func toMilleagePaceString() -> String {
        let milesPerHour = self.converted(to: UnitSpeed.milesPerHour).value
        if milesPerHour == 0 {
            return "--'--''"
        }

        let milesPerSec = milesPerHour / 3600
        let secsForMile = Int.init(1 / milesPerSec)
        return String(format: "%0.2d'%0.2d''", secsForMile / 60, secsForMile % 60)
    }
    
    func toMetricSpeedString() -> String {
        let kilometresPerHour = self.converted(to: UnitSpeed.kilometersPerHour).value
        return String(format: "%0.2d km/h", kilometresPerHour)
    }
    
    func toMilleageSpeedString() -> String {
        let milesPerHour = self.converted(to: UnitSpeed.milesPerHour).value
        return String(format: "%0.2d mi/h", milesPerHour)
    }
}
