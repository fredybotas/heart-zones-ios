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
        return (142, 190)
    } else if width == 156 {
        return (156, 300)
    } else if width == 184 {
        return (164, 300)
    }
    return (1000, 1000)
}

struct WorkoutRunningView: View {
    
    @ObservedObject var workoutViewModel: WorkoutViewModel

    var maxScreenSize: (Int, Int) = {
        return widthToMaxSize(width: WKInterfaceDevice.current().screenBounds.width)
    }()
    
    func getDeviceSizeMultiplier() -> CGFloat {
        let screenSize = self.maxScreenSize
        return CGFloat(screenSize.0) / kSmallestDeviceWidth
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text(workoutViewModel.time)
                .font(Font.system(size: 32 * getDeviceSizeMultiplier(), weight: .semibold, design: .default))
            Spacer(minLength: 8 * getDeviceSizeMultiplier())
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: nil) {
                    Text(workoutViewModel.bpm)
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 25 * getDeviceSizeMultiplier(), alignment: .leading)
                        .font(Font.system(size: 25 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
                    Text("")
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 4 * getDeviceSizeMultiplier(), alignment: .center)
                    Text(workoutViewModel.distance)
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(), alignment: .leading)
                        .font(Font.system(size: 22 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
                    Text(workoutViewModel.energy)
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(), alignment: .leading)
                        .font(Font.system(size: 22 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(workoutViewModel.bpmUnit)
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 25 * getDeviceSizeMultiplier(), alignment: .bottomLeading)
                        .font(Font.system(size: 18 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                    Text("")
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 4 * getDeviceSizeMultiplier(), alignment: .center)
                    Text(workoutViewModel.distanceUnit)
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(), alignment: .bottomLeading)
                        .font(Font.system(size: 14 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                    Text(workoutViewModel.energyUnit)
                        .frame(width: 50 * getDeviceSizeMultiplier(), height: 22 * getDeviceSizeMultiplier(), alignment: .bottomLeading)
                        .font(Font.system(size: 14 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                }
                VStack(alignment: .center, spacing: 8 * getDeviceSizeMultiplier()) {
                    PieSegment(ratio: workoutViewModel.bpmCircleRatio)
                        .fill(workoutViewModel.bpmCircleColor)
                        .frame(width: 20 * getDeviceSizeMultiplier(), height: 20 * getDeviceSizeMultiplier(), alignment: .center)
                        .padding(2.5 * getDeviceSizeMultiplier())
                    SunViewWithMinutes(minutesLeft: workoutViewModel.sunsetLeft, sunVisibility: workoutViewModel.sunVisibility)
                        .frame(width: 20 * getDeviceSizeMultiplier(), height: 40 * getDeviceSizeMultiplier(), alignment: .center)
                }
            }
            Spacer(minLength: 8 * getDeviceSizeMultiplier())
            HStack {
                Text(workoutViewModel.currentPace)
                    .font(Font.system(size: 18 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
                Spacer()
                Text(workoutViewModel.averagePace)
                    .font(Font.system(size: 18 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
            }
        }
        .onAppear(){
            workoutViewModel.startWorkout()
        }
        .navigationBarHidden(true)
        .frame(maxWidth: CGFloat(maxScreenSize.0), maxHeight: CGFloat(maxScreenSize.1), alignment: .leading)
    }
}

struct WorkoutRunningView_Previews: PreviewProvider {
    
    static var viewModel = WorkoutViewModel(workoutType: WorkoutType(type: .outdoorRunning), workoutService: WorkoutService(locationManager: LocationManager(), healthKitService: HealthKitService()), heartZoneService: HeartZoneService(workoutService: WorkoutService(locationManager: LocationManager(), healthKitService: HealthKitService()), beepingService: BeepingService(beeper: DeviceBeeper()), healthKitService: HealthKitService()), sunService: SunService(locationManager: LocationManager()))
    
    static var previews: some View {
        WorkoutRunningView(workoutViewModel: viewModel)
    }
}
