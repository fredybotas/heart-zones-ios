//
//  WorkoutMainView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI
import WatchKit

struct WorkoutMainView: View {
    enum Tab {
        case controls, workout, playing
    }

    let workoutType: WorkoutType
    @State private var selection: Tab = .workout

    var body: some View {
        // TODO: Fix tabview for watchOS 6
        //TabView(selection: $selection) {
       //     WorkoutControlsView().tag(Tab.controls)
            WorkoutRunningView()
                //.tag(Tab.workout)
            //NowPlayingView().tag(Tab.playing)
      //  }
        .navigationBarBackButtonHidden(true)
        .environmentObject(WorkoutViewModel(workoutType: workoutType))
    }
}

struct WorkoutMainView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutMainView(workoutType: WorkoutType(name: "Running", id: 1))
    }
}
