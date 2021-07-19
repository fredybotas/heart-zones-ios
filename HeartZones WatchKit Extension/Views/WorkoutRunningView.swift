//
//  WorkoutRunningView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI

struct WorkoutRunningView: View {
    
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text(workoutViewModel.time)
                .font(Font.system(size: 32, weight: .semibold, design: .default))
            Spacer()
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: nil) {
                    Text(workoutViewModel.bpm)
                        .frame(width: 50, height: 25, alignment: .leading)
                        .font(Font.system(size: 25, weight: .medium, design: .default))
                    Text("")
                        .frame(width: 50, height: 4, alignment: .center)
                    Text(workoutViewModel.distance)
                        .frame(width: 50, height: 22, alignment: .leading)
                        .font(Font.system(size: 22, weight: .medium, design: .default))
                    Text(workoutViewModel.energy)
                        .frame(width: 50, height: 22, alignment: .leading)
                        .font(Font.system(size: 22, weight: .medium, design: .default))
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(workoutViewModel.bpmUnit)
                        .frame(width: 50, height: 25, alignment: .bottomLeading)
                        .font(Font.system(size: 18, weight: .light, design: .default))
                    Text("")
                        .frame(width: 50, height: 4, alignment: .center)
                    Text(workoutViewModel.distanceUnit)
                        .frame(width: 50, height: 22, alignment: .bottomLeading)
                        .font(Font.system(size: 14, weight: .light, design: .default))
                    Text(workoutViewModel.energyUnit)
                        .frame(width: 50, height: 22, alignment: .bottomLeading)
                        .font(Font.system(size: 14, weight: .light, design: .default))
                }
                VStack(alignment: .center, spacing: 8) {
                    PieSegment(ratio: workoutViewModel.bpmCircleRatio)
                        .fill(workoutViewModel.bpmCircleColor)
                        .frame(width: 20, height: 20, alignment: .center)
                        .padding(2.5)
                    SunViewWithMinutes(minutesLeft: workoutViewModel.sunsetLeft, sunVisibility: workoutViewModel.sunVisibility)
                        .frame(width: 20, height: 40, alignment: .center)
                }
            }
            Spacer()
            HStack {
                Text(workoutViewModel.currentPace)
                    .font(Font.system(size: 18, weight: .medium, design: .default))
                Spacer()
                Text(workoutViewModel.averagePace)
                    .font(Font.system(size: 18, weight: .medium, design: .default))
            }
        }
        .onAppear(){
            workoutViewModel.startWorkout()
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct WorkoutRunningView_Previews: PreviewProvider {
    
    static var viewModel = WorkoutViewModel(workoutType: WorkoutType(type: .outdoorRunning), workoutService: WorkoutService(locationManager: LocationManager()), heartZoneService: HeartZoneService(workoutService: WorkoutService(locationManager: LocationManager()), beepingService: BeepingService(beeper: DeviceBeeper())), sunService: SunService(locationManager: LocationManager()))
    
    static var previews: some View {
        WorkoutRunningView(workoutViewModel: viewModel)
    }
}
