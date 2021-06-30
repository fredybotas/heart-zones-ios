//
//  WorkoutControlsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI

struct WorkoutControlsView: View {
    @ObservedObject var workoutControlsViewModel: WorkoutControlsViewModel
    var controller: HostingControllerWorkoutControls?

    var body: some View {
        HStack {
            VStack {
                Button{
                    workoutControlsViewModel.stopWorkout()
                    controller?.popControllers()
                } label: {
                    Image(systemName: "xmark")
                }
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
                    .font(Font.system(size: 25, weight: .regular, design: .default))
                    Text("Pause")
                } else {
                    Button{
                        workoutControlsViewModel.resumeWorkout()
                    } label: {
                        Image(systemName: "play")
                    }
                    .font(Font.system(size: 25, weight: .regular, design: .default))
                    Text("Continue")
                }
            }
        }
    }
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlsView(workoutControlsViewModel: WorkoutControlsViewModel(workoutService: WorkoutService()))
    }
}
