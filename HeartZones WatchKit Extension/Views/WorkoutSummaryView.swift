//
//  WorkoutSummaryView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 28/10/2021.
//

import SwiftUI

struct WorkoutSummaryUnitView: View {
    let name: String
    let values: [String]
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(name)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .font(Font.system(size: 10, weight: .light, design: .default))
                .foregroundColor(.gray)
            HStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Spacer()
                    ForEach(values, id: \.self) { value in
                        Text(value)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .font(Font.system(size: 24, weight: .medium, design: .default))
                            .frame(alignment: .bottom)
                            .padding([.bottom, .top], -2)
                    }
                }
                .frame(maxHeight: 35)
                Spacer()
                Text(unit)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .font(Font.system(size: 14, weight: .light, design: .default))
                    .frame(alignment: .bottom)

            }
        }
    }
}

struct WorkoutSummaryRow: View {
    let unitLeft: SummaryUnit?
    let unitRight: SummaryUnit?
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 1)
            Spacer(minLength: 5)
            HStack {
                WorkoutSummaryUnitView(name: unitLeft?.name ?? "", values: unitLeft?.values ?? [], unit: unitLeft?.unit ?? "")
                Spacer(minLength: 20)
                WorkoutSummaryUnitView(name: unitRight?.name ?? "", values: unitRight?.values ?? [], unit: unitRight?.unit ?? "")
            }
        }
    }
}

struct WorkoutSummaryView: View {
    weak var controller: HostingControllerWorkoutSummary?
    @ObservedObject var workoutSummaryViewModel: WorkoutSummaryViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                Text(workoutSummaryViewModel.workoutType)
                    .minimumScaleFactor(0.8)
                    .font(Font.footnote)
                    .foregroundColor(.gray)
                Text("ELAPSED TIME")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .font(Font.system(size: 10, weight: .light, design: .default))
                    .foregroundColor(.gray)
                Text(workoutSummaryViewModel.timeElapsed)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(Font.system(size: 46, weight: .semibold, design: .default))
                    .padding([.top], -5)
                
                ForEach(workoutSummaryViewModel.summaryUnits, id: \.self) { row in
                    WorkoutSummaryRow(unitLeft: row.left, unitRight: row.right)
                    Spacer(minLength: 3)
                }
                Rectangle()
                    .frame(height: 1)
                Spacer(minLength: 20)
                Button("Save Workout", action: {
                    workoutSummaryViewModel.saveWorkout()
                    controller?.popControllers()
                })
                Spacer(minLength: 15)
                Button("Discard", action: {
                    workoutSummaryViewModel.discardWorkout()
                    controller?.popControllers()
                })
            }
        }
    }
}

struct WorkoutSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSummaryView(workoutSummaryViewModel: WorkoutSummaryViewModel(workoutService: WorkoutService(locationManager: LocationManager(), healthKitService: HealthKitService(), settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())), settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}
