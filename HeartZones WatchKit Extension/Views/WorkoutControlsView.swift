//
//  WorkoutControlsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI

struct WorkoutControlsView: View {
    
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        HStack {
            VStack {
                Button{
                    workoutViewModel.stopWorkout()
                } label: {
                    Image(systemName: "xmark")
                }
                .font(.title2)
                Text("End")
            }
            VStack {
                if workoutViewModel.isRunning {
                    Button{
                        workoutViewModel.pauseWorkout()
                    } label: {
                        Image(systemName: "pause")
                    }
                    .font(.title2)
                    Text("Pause")
                } else {
                    Button{
                        workoutViewModel.startWorkout()
                    } label: {
                        Image(systemName: "play")
                    }
                    .font(.title2)
                    Text("Continue")
                }
            }
        }
    }
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlsView()
    }
}
