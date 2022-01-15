//
//  WorkoutRunningView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI
import WatchKit

let kSmallestDeviceWidth: CGFloat = 136.0
let kSmallestDeviceHeight: CGFloat = 170.0

func widthToMaxSize(width: CGFloat) -> (Int, Int) {
    if width == 136 {
        return (136, 300)
    } else if width == 162 {
        return (142, 300)
    } else if width == 156 {
        return (156, 300)
    } else if width == 184 {
        return (164, 300)
    } else if width == 176 {
        return (164, 300)
    } else if width == 198 {
        return (174, 300)
    }
    return (164, 300)
}

struct WorkoutRunningView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel

    var maxScreenSize: (Int, Int) = widthToMaxSize(width: WKInterfaceDevice.current().screenBounds.width)

    func getDeviceSizeMultiplier() -> CGFloat {
        let screenSize = maxScreenSize
        return CGFloat(screenSize.0) / kSmallestDeviceWidth
    }

    func getScreenOffsetY() -> CGFloat {
        if #available(watchOSApplicationExtension 7.0, *) {
            return -4
        }
        return -6
    }

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                Text(workoutViewModel.time)
                    .frame(height: 32 * getDeviceSizeMultiplier(), alignment: .leading)
                    .font(
                        Font.system(size: 32 * getDeviceSizeMultiplier(), weight: .semibold, design: .default))
                Spacer()
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(workoutViewModel.bpm)
                            .frame(
                                width: 53 * getDeviceSizeMultiplier(), height: 25 * getDeviceSizeMultiplier(),
                                alignment: .leading
                            )
                            .font(
                                Font.system(size: 25 * getDeviceSizeMultiplier(), weight: .medium, design: .default)
                            )
                        Text("")
                            .frame(
                                width: 53 * getDeviceSizeMultiplier(), height: 4 * getDeviceSizeMultiplier(),
                                alignment: .center
                            )
                        Text(workoutViewModel.fieldOne)
                            .frame(
                                width: 53 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(),
                                alignment: .leading
                            )
                            .font(
                                Font.system(size: 22 * getDeviceSizeMultiplier(), weight: .medium, design: .default)
                            )
                        Text(workoutViewModel.fieldTwo)
                            .frame(
                                width: 53 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(),
                                alignment: .leading
                            )
                            .font(
                                Font.system(size: 22 * getDeviceSizeMultiplier(), weight: .medium, design: .default)
                            )
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(workoutViewModel.bpmUnit)
                            .frame(
                                width: 50 * getDeviceSizeMultiplier(), height: 25 * getDeviceSizeMultiplier(),
                                alignment: .bottomLeading
                            )
                            .font(
                                Font.system(size: 16 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                        Text("")
                            .frame(
                                width: 50 * getDeviceSizeMultiplier(), height: 4 * getDeviceSizeMultiplier(),
                                alignment: .center
                            )
                        Text(workoutViewModel.fieldOneUnit)
                            .frame(
                                width: 50 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(),
                                alignment: .bottomLeading
                            )
                            .font(
                                Font.system(size: 12 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                        Text(workoutViewModel.fieldTwoUnit)
                            .frame(
                                width: 50 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(),
                                alignment: .bottomLeading
                            )
                            .font(
                                Font.system(size: 12 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                    }
                    VStack(alignment: .center, spacing: 8 * getDeviceSizeMultiplier()) {
                        ZStack(alignment: .center) {
                            PieSegment(ratio: workoutViewModel.bpmCircleRatio)
                                .fill(workoutViewModel.bpmCircleColor)
                                .frame(
                                    width: 29 * getDeviceSizeMultiplier(), height: 29 * getDeviceSizeMultiplier(),
                                    alignment: .center
                                )
                            //                            .padding(2.5 * getDeviceSizeMultiplier())
                            PieSegment(ratio: 1.0)
                                .fill(Color.black)
                                .frame(
                                    width: 24 * getDeviceSizeMultiplier(), height: 24 * getDeviceSizeMultiplier(),
                                    alignment: .center
                                )
                            //                            .padding(2.5 * getDeviceSizeMultiplier())
                            // Hack with new sdk causing, zstack to not center elements correctly
                            // .offset(x: 0.11, y: 0)
                            Text(String(workoutViewModel.bpmPercentage))
                                .foregroundColor(workoutViewModel.bpmCircleColor)
                                .frame(
                                    width: 25 * getDeviceSizeMultiplier(), height: 25 * getDeviceSizeMultiplier(),
                                    alignment: .center
                                )
                                .font(
                                    Font.system(
                                        size: 15 * getDeviceSizeMultiplier(), weight: .medium, design: .default
                                    )
                                )
                                .offset(x: 0, y: -0.1)
                        }
                        SunViewWithMinutes(
                            minutesLeft: workoutViewModel.sunsetLeft,
                            sunVisibility: workoutViewModel.sunVisibility,
                            fontSize: 15 * getDeviceSizeMultiplier()
                        )
                        .frame(
                            width: 20 * getDeviceSizeMultiplier(), height: 40 * getDeviceSizeMultiplier(),
                            alignment: .center
                        )
                    }
                }
                Spacer()
                HStack {
                    Text(workoutViewModel.currentPace)
                        .frame(height: 18 * getDeviceSizeMultiplier(), alignment: .leading)
                        .font(
                            Font.system(size: 18 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
                    Spacer()
                    Text(workoutViewModel.averagePace)
                        .frame(height: 18 * getDeviceSizeMultiplier(), alignment: .trailing)
                        .font(
                            Font.system(size: 18 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height - 12, alignment: .topLeading)
            .offset(x: 0, y: getScreenOffsetY())
            .onAppear {
                workoutViewModel.startWorkout()
            }
            .navigationBarHidden(true)
        }
        .frame(width: CGFloat(maxScreenSize.0), alignment: .center)
        .edgesIgnoringSafeArea([.bottom])
    }
}

struct WorkoutRunningView_Previews: PreviewProvider {
    static var viewModel = WorkoutViewModel(
        workoutType: WorkoutType(type: .outdoorRunning),
        workoutService: WorkoutService(
            locationManager: LocationManager(), healthKitService: HealthKitService(),
            settingsService: SettingsService(
                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
            )
        ),
        heartZoneService: HeartZoneService(
            workoutService: WorkoutService(
                locationManager: LocationManager(), healthKitService: HealthKitService(),
                settingsService: SettingsService(
                    settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                )
            ),
            beepingService: BeepingService(
                beeper: DeviceBeepingManager(beeper: DeviceBeeper()),
                settingsService: SettingsService(
                    settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                )
            ),
            healthKitService: HealthKitService(),
            settingsService: SettingsService(
                settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
            )
        ),
        sunService: SunService(locationManager: LocationManager()),
        settingsService: SettingsService(
            settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
        )
    )

    static var previews: some View {
        Group {
            WorkoutRunningView(workoutViewModel: viewModel)
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 3 - 38mm"))
                .previewDisplayName("38mm")
            WorkoutRunningView(workoutViewModel: viewModel)
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 3 - 42mm"))
                .previewDisplayName("42mm")
            WorkoutRunningView(workoutViewModel: viewModel)
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
                .previewDisplayName("40mm")
            WorkoutRunningView(workoutViewModel: viewModel)
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
                .previewDisplayName("44mm")
            WorkoutRunningView(workoutViewModel: viewModel)
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 41mm"))
                .previewDisplayName("41mm")
            WorkoutRunningView(workoutViewModel: viewModel)
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
                .previewDisplayName("45mm")
        }
    }
}
