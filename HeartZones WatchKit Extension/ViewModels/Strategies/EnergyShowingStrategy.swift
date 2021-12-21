//
//  EnergyShowingStrategy.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 08/08/2021.
//

import Foundation

protocol IEnergyShowingStrategy {
    func getEnergyValue(_ data: Measurement<UnitEnergy>) -> String?
    func getEnergyMetric(_ data: Measurement<UnitEnergy>) -> String

    var defaultEnergyValue: String { get }
    var defaultEnergyUnit: String { get }
}

class EnergyKcalShowingStrategy: IEnergyShowingStrategy {
    var defaultEnergyValue: String {
        "0"
    }

    var defaultEnergyUnit: String {
        "KCAL"
    }

    private let energyFormatter = MeasurementFormatter()

    init() {
        energyFormatter.unitOptions = .providedUnit
        energyFormatter.unitStyle = .medium
        energyFormatter.numberFormatter.maximumFractionDigits = 0
        energyFormatter.numberFormatter.usesGroupingSeparator = false
    }

    func getEnergyValue(_ data: Measurement<UnitEnergy>) -> String? {
        let data = data.converted(to: UnitEnergy.kilocalories)
        return energyFormatter.numberFormatter.string(from: NSNumber(value: data.value))
    }

    func getEnergyMetric(_ data: Measurement<UnitEnergy>) -> String {
        let data = data.converted(to: UnitEnergy.kilocalories)
        return energyFormatter.string(from: data.unit).uppercased()
    }
}

class EnergyKJShowingStrategy: IEnergyShowingStrategy {
    var defaultEnergyValue: String {
        "0"
    }

    var defaultEnergyUnit: String {
        "KJ"
    }

    private let energyFormatter = MeasurementFormatter()

    init() {
        energyFormatter.unitOptions = .providedUnit
        energyFormatter.unitStyle = .short
        energyFormatter.numberFormatter.maximumFractionDigits = 0
        energyFormatter.numberFormatter.usesGroupingSeparator = false
    }

    func getEnergyValue(_ data: Measurement<UnitEnergy>) -> String? {
        let data = data.converted(to: UnitEnergy.kilojoules)
        return energyFormatter.numberFormatter.string(from: NSNumber(value: data.value))
    }

    func getEnergyMetric(_ data: Measurement<UnitEnergy>) -> String {
        let data = data.converted(to: UnitEnergy.kilojoules)
        return energyFormatter.string(from: data.unit).uppercased()
    }
}
