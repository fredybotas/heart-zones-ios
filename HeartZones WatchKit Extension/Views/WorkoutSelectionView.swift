//
//  WorkoutSelectionView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import HealthKit
import SwiftUI

struct WorkoutSelectionView: View {
    @ObservedObject var workoutSelectionViewModel: WorkoutSelectionViewModel

    var body: some View {
        List {
            ForEach(workoutSelectionViewModel.workoutTypes) { workoutType in
                Button(
                    workoutType.name,
                    action: {
                        HostingControllerWorkoutSelection.presentRunningWorkoutController(workoutType: workoutType)
                    }
                )
                .font(Font.system(size: 14, weight: .regular, design: .default))
                .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3))
            }
            Button("Read only mode",
                   action: {
                       HostingControllerWorkoutSelection.presentReadOnlyMode()
                   })
            Divider()
                .frame(maxHeight: 2)
                .listRowPlatterColor(.clear)
            NavigationLink(
                destination: LazyView(
                    SettingsView(settingsViewModel: DIContainer.shared.resolve(SettingsViewModel.self)!))
            ) {
                Text("Settings")
                    .font(Font.system(size: 14, weight: .regular, design: .default))
                    .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 3))
            }
            .listRowPlatterColor(Color(red: 36 / 255, green: 123 / 255, blue: 160 / 255))
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
