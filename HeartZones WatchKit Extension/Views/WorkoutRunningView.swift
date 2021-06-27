//
//  WorkoutRunningView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI

struct WorkoutRunningView: View {
    
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text(workoutViewModel.time).font(Font.system(size: 32, weight: .semibold, design: .default))
            Spacer()
            HStack(alignment: .center, spacing: 20) {
                Text(String(workoutViewModel.bpm) + " bpm").font(Font.system(size: 25, weight: .regular, design: .default))
                PieSegment(ratio: 0.5)
                    .fill(Color.red)
                    .frame(width: 22, height: 22, alignment: .center)
            }
            .padding([.bottom, .top], -5)
            
            Text(String(workoutViewModel.energy) + " kcal").font(Font.system(size: 25, weight: .regular, design: .default))
                .padding([.bottom, .top], -5)
            Text(String(workoutViewModel.distance) + " km").font(Font.system(size: 25, weight: .regular, design: .default))
                .padding([.bottom, .top], -5)
            Spacer()
            HStack {
                Text(workoutViewModel.currentPace).font(Font.system(size: 25, weight: .regular, design: .default))
                Spacer()
                Text(workoutViewModel.averagePace).font(Font.system(size: 25, weight: .regular, design: .default))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct WorkoutRunningView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRunningView()
    }
}
