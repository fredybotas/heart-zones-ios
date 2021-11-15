//
//  DistanceShowingStrategy.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/08/2021.
//

import Foundation

protocol IDistanceShowingStrategy {
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String, String)?
    func getDistanceValueAndUnit(_ data: Measurement<UnitLength>) -> (String, String)?
    
    func getCurrentPace(_ data: DistanceData) -> String
    func getAveragePace(_ data: DistanceData) -> String

    func getPaceValueAndUnit(_ data: Measurement<UnitSpeed>) -> (String, String)
    
    var defaultPaceName: String { get }
    var defaultDistanceUnit: String { get }
    var defaultPaceString: String { get }
    var defaultPaceUnit: String { get }
    var defaultDistanceValue: String { get }
}

// TODO: Refactor strategies
class MetricDistanceWithPaceShowingStrategy: IDistanceShowingStrategy {
    var defaultPaceName: String {
        get {
            "AVG PACE"
        }
    }
    var defaultPaceUnit: String {
        get {
            ""
        }
    }

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
    
    func getDistanceValueAndUnit(_ data: Measurement<UnitLength>) -> (String, String)? {
        data.toMetricLengthValueAndUnitString()
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String, String)? {
        data.distance.toMetricLengthValueAndUnitString()
    }

    func getCurrentPace(_ data: DistanceData) -> String {
        data.currentSpeed.toMetricPaceString() ?? defaultPaceString
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        data.averageSpeed.toMetricPaceString() ?? defaultPaceString
    }
    
    func getPaceValueAndUnit(_ data: Measurement<UnitSpeed>) -> (String, String) {
        return (data.toMetricPaceString() ?? defaultPaceString, "")
    }
}

class MilleageDistanceWithPaceShowingStrategy: IDistanceShowingStrategy {
    var defaultPaceName: String {
        get {
            "AVG PACE"
        }
    }
    
    var defaultPaceUnit: String {
        get {
            ""
        }
    }
    
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
    
    func getDistanceValueAndUnit(_ data: Measurement<UnitLength>) -> (String, String)? {
        data.toMilleageLengthValueAndUnitString()
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String, String)? {
        data.distance.toMilleageLengthValueAndUnitString()
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        data.currentSpeed.toMilleagePaceString() ?? defaultPaceString
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        data.averageSpeed.toMilleagePaceString() ?? defaultPaceString
    }
    
    func getPaceValueAndUnit(_ data: Measurement<UnitSpeed>) -> (String, String) {
        return (data.toMilleagePaceString() ?? defaultPaceString, "")
    }
}

class MetricDistanceWithSpeedShowingStrategy: IDistanceShowingStrategy {
    var defaultPaceName: String {
        get {
            "AVG SPEED"
        }
    }
    
    var defaultPaceUnit: String {
        get {
            "KM/H"
        }
    }
    
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
    
    func getDistanceValueAndUnit(_ data: Measurement<UnitLength>) -> (String, String)? {
        data.toMetricLengthValueAndUnitString()
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String, String)? {
        data.distance.toMetricLengthValueAndUnitString()
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        data.currentSpeed.toMetricSpeedString().uppercased()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        data.averageSpeed.toMetricSpeedString().uppercased()
    }
    
    func getPaceValueAndUnit(_ data: Measurement<UnitSpeed>) -> (String, String) {
        return (data.toMetricSpeedString(), defaultPaceUnit)
    }
}

class MilleageDistanceWithSpeedShowingStrategy: IDistanceShowingStrategy {
    var defaultPaceName: String {
        get {
            "AVG SPEED"
        }
    }
    
    var defaultPaceUnit: String {
        get {
            "MI/H"
        }
    }
    
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
    func getDistanceValueAndUnit(_ data: Measurement<UnitLength>) -> (String, String)? {
        data.toMilleageLengthValueAndUnitString()
    }
    
    func getDistanceValueAndUnit(_ data: DistanceData) -> (String, String)? {
        data.distance.toMilleageLengthValueAndUnitString()
    }
    
    func getCurrentPace(_ data: DistanceData) -> String {
        data.currentSpeed.toMilleageSpeedString().uppercased()
    }
    
    func getAveragePace(_ data: DistanceData) -> String {
        data.averageSpeed.toMilleageSpeedString().uppercased()
    }
    
    func getPaceValueAndUnit(_ data: Measurement<UnitSpeed>) -> (String, String) {
        return (data.toMilleageSpeedString(), defaultPaceUnit)
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
    func toMetricLengthValueAndUnitString() -> (String, String)? {
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
            return nil
        }
        
        return (String(valueAndUnitArray[0]), valueAndUnitArray[1].uppercased())
    }
    
    func toMilleageLengthValueAndUnitString() -> (String, String)? {
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
            return nil
        }
        
        return (String(valueAndUnitArray[0]), valueAndUnitArray[1].uppercased())
    }
}
