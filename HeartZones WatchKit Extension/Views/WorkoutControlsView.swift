//
//  WorkoutControlsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI

struct WorkoutControlsView: View {
    @ObservedObject var workoutControlsViewModel: WorkoutControlsViewModel
    weak var controller: HostingControllerWorkoutControls?

    var body: some View {
        HStack {
            VStack {
                Button{
                    workoutControlsViewModel.stopWorkout()
                    controller?.popControllers()
                } label: {
                    Image(systemName: "xmark")
                }
                .padding(8)
                .font(Font.system(size: 25, weight: .regular, design: .default))
                Text("End")
            }
            VStack {
                if workoutControlsViewModel.isRunning {
                    Button{
                        workoutControlsViewModel.pauseWorkout()
                    } label: {
                        Image(systemName: "pause")
                    }
                    .padding(8)
                    .font(Font.system(size: 25, weight: .regular, design: .default))
                    Text("Pause")
                } else {
                    Button{
                        workoutControlsViewModel.resumeWorkout()
                        controller?.setPageToRunningWorkout()
                    } label: {
                        Image(systemName: "play")
                    }
                    .padding(8)
                    .font(Font.system(size: 25, weight: .regular, design: .default))
                    Text("Continue")
                }
            }
        }
    }
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlsView(workoutControlsViewModel: WorkoutControlsViewModel(workoutService: WorkoutService(locationManager: LocationManager(), healthKitService: HealthKitService())))
    }
}
