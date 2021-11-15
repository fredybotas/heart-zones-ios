//
//  SummaryDataProcessingStrategy.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 11/11/2021.
//

import Foundation


protocol ISummaryDataProcessingStrategy {
    func processSummaryData(workoutSummaryData: WorkoutSummaryData) -> [SummaryRow]
    func getDefault() -> [SummaryRow]
}

internal let kBpmAverageString = "AVG BPM"
internal let kDistanceString = "DISTANCE"
internal let kPaceAverageString = "AVG PACE"
internal let kTimeInTargetZoneString = "TIME IN TARGET ZONE"
internal let kBpmUnit = "BPM"
internal let kEnergyString = "ENERGY"
internal let kMinMaxElevation = "MIN MAX ELEVATION"
internal let kElevationGain = "ELEVATION GAIN"

class SummaryDataProcessingStrategy: ISummaryDataProcessingStrategy {
    
    let showingStrategyFacade: ShowingStrategyFacade
    
    init(showingStrategyFacade: ShowingStrategyFacade) {
        self.showingStrategyFacade = showingStrategyFacade
    }
    
    func processSummaryData(workoutSummaryData: WorkoutSummaryData) -> [SummaryRow] {
                
        var summaryUnits = [SummaryRow]()
        summaryUnits.append(getFirstRow(workoutSummaryData: workoutSummaryData))
        summaryUnits.append(getSecondRow(workoutSummaryData: workoutSummaryData))
        summaryUnits.append(getThirdRow(workoutSummaryData: workoutSummaryData))
        summaryUnits.append(getFourthRow(workoutSummaryData: workoutSummaryData))
        return summaryUnits
    }
    
    private func getFirstRow(workoutSummaryData: WorkoutSummaryData) -> SummaryRow {
        var bpmUnit: SummaryUnit!
        if let avgBpm = workoutSummaryData.avgBpm {
            bpmUnit = SummaryUnit(name: kBpmAverageString, values: [String(avgBpm)], unit: kBpmUnit)
        } else {
            bpmUnit = SummaryUnit(name: kBpmAverageString, values: ["--"], unit: kBpmUnit)
        }
        let percentageSummaryUnit = SummaryUnit(name: kTimeInTargetZoneString, values: [String(workoutSummaryData.timeInTargetZonePercentage)], unit: "%")
        return SummaryRow(left: bpmUnit, right: percentageSummaryUnit)
    }
    
    private func getSecondRow(workoutSummaryData: WorkoutSummaryData) -> SummaryRow {
        var distanceUnit: SummaryUnit!
        if let distance = workoutSummaryData.distance {
            if let tuple = showingStrategyFacade.distanceShowingStrategy.getDistanceValueAndUnit(distance) {
                distanceUnit = SummaryUnit(name: kDistanceString, values: [tuple.0], unit: tuple.1)
            } else {
                distanceUnit = SummaryUnit(name: kDistanceString, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)
            }
        } else {
            distanceUnit = SummaryUnit(name: kDistanceString, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)
        }
        
        var paceUnit: SummaryUnit!
        if let speed = workoutSummaryData.averagePace {
            let tup = showingStrategyFacade.distanceShowingStrategy.getPaceValueAndUnit(speed)
            paceUnit = SummaryUnit(name: showingStrategyFacade.distanceShowingStrategy.defaultPaceName, values: [tup.0], unit: tup.1)
        } else {
            paceUnit = SummaryUnit(name: showingStrategyFacade.distanceShowingStrategy.defaultPaceName, values: [showingStrategyFacade.distanceShowingStrategy.defaultPaceString], unit: "")
        }
        return SummaryRow(left: distanceUnit, right: paceUnit)
    }
    
    private func getThirdRow(workoutSummaryData: WorkoutSummaryData) -> SummaryRow {
        var elevationGainUnit: SummaryUnit!
        if let elevationGain = workoutSummaryData.elevationGain {
            if let tuple = showingStrategyFacade.distanceShowingStrategy.getDistanceValueAndUnit(elevationGain) {
                elevationGainUnit = SummaryUnit(name: kElevationGain, values: [tuple.0], unit: tuple.1)
            } else {
                elevationGainUnit = SummaryUnit(name: kElevationGain, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)
            }
        } else {
            elevationGainUnit = SummaryUnit(name: kElevationGain, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)
        }
        
        var minMaxElevationUnit: SummaryUnit!
        if let minElevation = workoutSummaryData.elevationMin, let maxElevation = workoutSummaryData.elevationMax {
            let minTup = showingStrategyFacade.distanceShowingStrategy.getDistanceValueAndUnit(minElevation)
            let maxTup = showingStrategyFacade.distanceShowingStrategy.getDistanceValueAndUnit(maxElevation)
            if let minTup = minTup , let maxTup = maxTup  {
                minMaxElevationUnit = SummaryUnit(name: kMinMaxElevation, values: [minTup.0, maxTup.0], unit: maxTup.1)
            } else {
                minMaxElevationUnit = SummaryUnit(name: kMinMaxElevation, values: ["--", "--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)
            }
        } else {
            minMaxElevationUnit = SummaryUnit(name: kMinMaxElevation, values: ["--", "--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)
        }
        
        return SummaryRow(left: elevationGainUnit, right: minMaxElevationUnit)
    }
    
    private func getFourthRow(workoutSummaryData: WorkoutSummaryData) -> SummaryRow {
        var activeEnergyUnit: SummaryUnit!
        if let energy = workoutSummaryData.activeEnergy {
            if let energyValue = showingStrategyFacade.energyShowingStrategy.getEnergyValue(energy) {
                activeEnergyUnit = SummaryUnit(name: kEnergyString, values: [energyValue], unit: showingStrategyFacade.energyShowingStrategy.getEnergyMetric(energy))
            } else {
                activeEnergyUnit = SummaryUnit(name: kEnergyString, values: ["--"], unit: showingStrategyFacade.energyShowingStrategy.defaultEnergyUnit)
            }
        } else {
            activeEnergyUnit = SummaryUnit(name: kEnergyString, values: ["--"], unit: showingStrategyFacade.energyShowingStrategy.defaultEnergyUnit)
        }
        return SummaryRow(left: activeEnergyUnit, right: nil)
    }
    
    func getDefault() -> [SummaryRow] {
        return [
            SummaryRow(left: SummaryUnit(name: kBpmAverageString, values: ["--"], unit: kBpmUnit), right: SummaryUnit(name: kTimeInTargetZoneString, values: ["--"], unit: "%")),
            SummaryRow(left: SummaryUnit(name: kDistanceString, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit), right: SummaryUnit(name: showingStrategyFacade.distanceShowingStrategy.defaultPaceName, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultPaceUnit)),
            SummaryRow(left: SummaryUnit(name: kElevationGain, values: ["--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit), right: SummaryUnit(name: kMinMaxElevation, values: ["--", "--"], unit: showingStrategyFacade.distanceShowingStrategy.defaultDistanceUnit)),
            SummaryRow(left: SummaryUnit(name: kEnergyString, values: ["--"], unit: showingStrategyFacade.energyShowingStrategy.defaultEnergyUnit), right: nil)
        ]
    }
}
