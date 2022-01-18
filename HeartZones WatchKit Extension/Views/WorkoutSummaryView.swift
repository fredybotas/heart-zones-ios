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
    let color: Color?

    // TODO: Unify coef multiplier across screens
    var maxScreenSize: (Int, Int) = widthToMaxSize(width: WKInterfaceDevice.current().screenBounds.width)

    func getDeviceSizeMultiplier() -> CGFloat {
        let screenSize = maxScreenSize
        return CGFloat(screenSize.0) / kSmallestDeviceWidth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(name)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(Font.system(size: 9 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                .foregroundColor(.gray)
            HStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Spacer()
                    ForEach(values, id: \.self) { value in
                        Text(value)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .font(
                                Font.system(size: 22 * getDeviceSizeMultiplier(), weight: .medium, design: .default)
                            )
                            .foregroundColor(color)
                            .frame(alignment: .bottom)
                            .padding([.bottom, .top], -2)
                    }
                }
                .frame(maxHeight: 42)
                Spacer()
                Text(unit)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(Font.system(size: 8 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                    .foregroundColor(color)
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
            HStack(spacing: 15) {
                WorkoutSummaryUnitView(
                    name: unitLeft?.name ?? "", values: unitLeft?.values ?? [], unit: unitLeft?.unit ?? "",
                    color: unitLeft?.color
                )
                WorkoutSummaryUnitView(
                    name: unitRight?.name ?? "", values: unitRight?.values ?? [], unit: unitRight?.unit ?? "",
                    color: unitRight?.color
                )
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
                    .minimumScaleFactor(0.5)
                    .font(Font.footnote)
                    .foregroundColor(.gray)
                Text("ELAPSED TIME")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
                if workoutSummaryViewModel.showSaveButton {
                    Button(
                        "Save Workout",
                        action: {
                            workoutSummaryViewModel.saveWorkout()
                            controller?.popControllers()
                        }
                    )
                }
                Spacer(minLength: 10)
                Button(
                    "Discard",
                    action: {
                        workoutSummaryViewModel.discardWorkout()
                        controller?.popControllers()
                    }
                )
            }
        }
    }
}

struct WorkoutSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkoutSummaryView(
                workoutSummaryViewModel: WorkoutSummaryViewModel(
                    workoutService: WorkoutService(
                        locationManager: LocationManager(), healthKitService: HealthKitService(),
                        settingsService: SettingsService(
                            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                        ), zoneStatisticsCalculator:
                        ZoneStatisticsCalculator(
                            settingsService: SettingsService(
                                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                            ))
                    ),
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    )
                )
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 3 - 38mm"))
            .previewDisplayName("38mm")
            WorkoutSummaryView(
                workoutSummaryViewModel: WorkoutSummaryViewModel(
                    workoutService: WorkoutService(
                        locationManager: LocationManager(), healthKitService: HealthKitService(),
                        settingsService: SettingsService(
                            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                        ), zoneStatisticsCalculator:
                        ZoneStatisticsCalculator(
                            settingsService: SettingsService(
                                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                            ))
                    ),
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    )
                )
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 3 - 42mm"))
            .previewDisplayName("42mm")
            WorkoutSummaryView(
                workoutSummaryViewModel: WorkoutSummaryViewModel(
                    workoutService: WorkoutService(
                        locationManager: LocationManager(), healthKitService: HealthKitService(),
                        settingsService: SettingsService(
                            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                        ), zoneStatisticsCalculator:
                        ZoneStatisticsCalculator(
                            settingsService: SettingsService(
                                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                            ))
                    ),
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    )
                )
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
            .previewDisplayName("40mm")
            WorkoutSummaryView(
                workoutSummaryViewModel: WorkoutSummaryViewModel(
                    workoutService: WorkoutService(
                        locationManager: LocationManager(), healthKitService: HealthKitService(),
                        settingsService: SettingsService(
                            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                        ), zoneStatisticsCalculator:
                        ZoneStatisticsCalculator(
                            settingsService: SettingsService(
                                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                            ))
                    ),
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    )
                )
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
            .previewDisplayName("44mm")
            WorkoutSummaryView(
                workoutSummaryViewModel: WorkoutSummaryViewModel(
                    workoutService: WorkoutService(
                        locationManager: LocationManager(), healthKitService: HealthKitService(),
                        settingsService: SettingsService(
                            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                        ), zoneStatisticsCalculator:
                        ZoneStatisticsCalculator(
                            settingsService: SettingsService(
                                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                            ))
                    ),
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    )
                )
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 41mm"))
            .previewDisplayName("41mm")
            WorkoutSummaryView(
                workoutSummaryViewModel: WorkoutSummaryViewModel(
                    workoutService: WorkoutService(
                        locationManager: LocationManager(), healthKitService: HealthKitService(),
                        settingsService: SettingsService(
                            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                        ), zoneStatisticsCalculator:
                        ZoneStatisticsCalculator(
                            settingsService: SettingsService(
                                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                            ))
                    ),
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    )
                )
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
            .previewDisplayName("45mm")
        }
    }
}
