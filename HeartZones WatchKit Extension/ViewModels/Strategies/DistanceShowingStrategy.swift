//
//  DistanceShowingStrategy.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/08/2021.
//

import Foundation

protocol IDistanceShowingStrategy {
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String?, String?)

    func getCurrentPace(_ data: DistanceData) -> String
    func getAveragePace(_ data: DistanceData) -> String

    var defaultDistanceUnit: String { get }
    var defaultPaceString: String { get }
    var defaultDistanceValue: String { get }
}

// TODO: Refactor strategies
class MetricDistanceWithPaceShowingStrategy: IDistanceShowingStrategy {
    var defaultDistanceValue: String {
        get {
            "0"
        }
    }
    
    var defaultDistanceUnit: String {
        get {
            "M"
        }
    }
    
    var defaultPaceString: String {
        get {
            "--'--''"
        }
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String?, String?) {
        return data.distance.toMetricLengthValueAndUnitString()
    }

    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMetricPaceString() ?? defaultPaceString
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMetricPaceString() ?? defaultPaceString
    }
}

class MilleageDistanceWithPaceShowingStrategy: IDistanceShowingStrategy {
    var defaultDistanceValue: String {
        get {
            "0"
        }
    }
    
    var defaultDistanceUnit: String {
        get {
            "FT"
        }
    }
    
    var defaultPaceString: String {
        get {
            "--'--''"
        }
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String?, String?) {
        return data.distance.toMilleageLengthValueAndUnitString()
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMilleagePaceString() ?? defaultPaceString
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMilleagePaceString() ?? defaultPaceString
    }
}

class MetricDistanceWithSpeedShowingStrategy: IDistanceShowingStrategy {
    var defaultDistanceValue: String {
        get {
            "0"
        }
    }
    
    var defaultDistanceUnit: String {
        get {
            "M"
        }
    }
    
    var defaultPaceString: String {
        get {
            "--'--''"
        }
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String?, String?) {
        return data.distance.toMetricLengthValueAndUnitString()
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMetricSpeedString().uppercased()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMetricSpeedString().uppercased()
    }
}

class MilleageDistanceWithSpeedShowingStrategy: IDistanceShowingStrategy {
    var defaultDistanceValue: String {
        get {
            "0"
        }
    }
    
    var defaultDistanceUnit: String {
        get {
            "FT"
        }
    }
    
    var defaultPaceString: String {
        get {
            "--'--''"
        }
    }
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String?, String?) {
        return data.distance.toMilleageLengthValueAndUnitString()
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        return data.currentSpeed.toMilleageSpeedString().uppercased()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        return data.averageSpeed.toMilleageSpeedString().uppercased()
    }
}

fileprivate extension Measurement where UnitType == UnitSpeed {
    func toMetricPaceString() -> String? {
        let metresPerSec = self.converted(to: UnitSpeed.metersPerSecond).value
        if metresPerSec == 0 {
            return nil
        }
        let kilometresPerSec = metresPerSec / 1000
        let secsForKilometer = Int.init(1 / kilometresPerSec)
        return String(format: "%0.2d'%0.2d''", secsForKilometer / 60, secsForKilometer % 60)
    }
    
    func toMilleagePaceString() -> String? {
        let milesPerHour = self.converted(to: UnitSpeed.milesPerHour).value
        if milesPerHour == 0 {
            return nil
        }
        let milesPerSec = milesPerHour / 3600
        let secsForMile = Int.init(1 / milesPerSec)
        return String(format: "%0.2d'%0.2d''", secsForMile / 60, secsForMile % 60)
    }
    
    func toMetricSpeedString() -> String {
        let kilometresPerHour = self.converted(to: UnitSpeed.kilometersPerHour).value
        return String(format: "%0.2f", kilometresPerHour)
    }
    
    func toMilleageSpeedString() -> String {
        let milesPerHour = self.converted(to: UnitSpeed.milesPerHour).value
        return String(format: "%0.2f", milesPerHour)
    }
}

fileprivate extension Measurement where UnitType == UnitLength {
    func toMetricLengthValueAndUnitString() -> (String?, String?) {
        var unit = UnitLength.kilometers
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        if self < Measurement.init(value: 1, unit: UnitLength.kilometers) {
            formatter.numberFormatter.maximumFractionDigits = 0
            unit = UnitLength.meters
        } else if self >= Measurement.init(value: 100, unit: UnitLength.kilometers) {
            formatter.numberFormatter.maximumFractionDigits = 0
        } else {
            formatter.numberFormatter.maximumFractionDigits = 1
            formatter.numberFormatter.minimumFractionDigits = 1
        }
        let valueAndUnitArray = formatter.string(from: self.converted(to: unit)).split(separator: " ")
        if valueAndUnitArray.count < 2 {
            return (nil, nil)
        }
        
        return (String(valueAndUnitArray[0]), valueAndUnitArray[1].uppercased())
    }
    
    func toMilleageLengthValueAndUnitString() -> (String?, String?) {
        var unit = UnitLength.miles
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        if self < Measurement.init(value: 1, unit: UnitLength.miles) {
            formatter.numberFormatter.maximumFractionDigits = 0
            formatter.numberFormatter.usesGroupingSeparator = false
            unit = UnitLength.feet
        } else if self >= Measurement.init(value: 100, unit: UnitLength.miles) {
            formatter.numberFormatter.maximumFractionDigits = 0
        } else {
            formatter.numberFormatter.maximumFractionDigits = 1
            formatter.numberFormatter.minimumFractionDigits = 1
        }
        let valueAndUnitArray = formatter.string(from: self.converted(to: unit)).split(separator: " ")
        if valueAndUnitArray.count < 2 {
            return (nil, nil)
        }
        
        return (String(valueAndUnitArray[0]), valueAndUnitArray[1].uppercased())    }
}
