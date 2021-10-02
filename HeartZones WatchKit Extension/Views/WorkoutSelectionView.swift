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
    weak var controller: HostingControllerWorkoutSelection!
    
    var body: some View {
        List {
            ForEach(workoutSelectionViewModel.workoutTypes) { workoutType in
                Button(workoutType.name, action: {
                        controller?.presentRunningWorkoutController(workoutType: workoutType)
                    })
                    .font(Font.system(size: 14, weight: .regular, design: .default))
                    .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3))
            }
            Divider()
                .frame(maxHeight: 2)
                .listRowPlatterColor(.clear)
            NavigationLink(destination: LazyView(SettingsView(settingsViewModel: controller.container.resolve(SettingsViewModel.self)!, heartZoneSettingsViewModel: controller.container.resolve(HeartZoneSettingsViewModel.self)!))) {
                Text("Settings")
            }
            .listRowPlatterColor(.blue)
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
