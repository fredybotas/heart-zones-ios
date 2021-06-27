//
//  WorkoutSelectionView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI
import HealthKit

struct WorkoutType: Identifiable {
    var name: String
    var id: Int
}

struct WorkoutSelectionView: View {
    var workoutTypes: [WorkoutType] = [WorkoutType(name: "Outdoor Running", id: 1)]
    
    var body: some View {
        List(workoutTypes){ workoutType in
            NavigationLink(workoutType.name, destination: WorkoutMainView())
                .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
        }
        .listStyle(CarouselListStyle())
        .navigationBarTitle("Workouts")
    }
}

struct WorkoutSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSelectionView()
    }
}
