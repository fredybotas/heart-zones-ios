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

    @State private var selection: Tab = .workout

    var body: some View {
        TabView(selection: $selection) {
            WorkoutControlsView().tag(Tab.controls)
            WorkoutRunningView().tag(Tab.workout)
            NowPlayingView().tag(Tab.playing)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct WorkoutMainView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutMainView()
    }
}
