//
//  WorkoutSelectionView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI
import HealthKit

struct WorkoutSelectionView: View {
    
    @ObservedObject var workoutSelectionViewModel: WorkoutSelectionViewModel
    
    var controller: HostingControllerWorkoutSelection?
    
    var body: some View {
        List(workoutSelectionViewModel.workoutTypes){ workoutType in            
            Button(workoutType.name, action: {
                controller?.presentRunningWorkoutController(workoutType: workoutType)
            })
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
        }
        .listStyle(CarouselListStyle())
        .navigationBarTitle("Workouts")
    }
}

struct WorkoutSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSelectionView(workoutSelectionViewModel: WorkoutSelectionViewModel())
    }
}
