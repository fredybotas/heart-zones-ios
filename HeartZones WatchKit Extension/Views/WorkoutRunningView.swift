//
//  WorkoutRunningView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/06/2021.
//

import SwiftUI

struct WorkoutRunningView: View {
    
    @ObservedObject var workoutViewModel: WorkoutViewModel

    private func getBpmViewPadding() -> CGFloat {
        if #available(watchOS 7, *) {
            return -5
        }
        return -15
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            Text(workoutViewModel.time).font(Font.system(size: 32, weight: .semibold, design: .default))
            Spacer()
            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: nil) {
                    Text(workoutViewModel.bpm)
                        .font(Font.system(size: 23, weight: .light, design: .default))
                        .padding([.bottom, .top], getBpmViewPadding())
                    Text(workoutViewModel.energy)
                        .font(Font.system(size: 23, weight: .light, design: .default))
                        .padding([.bottom, .top], -5)
                    Text(workoutViewModel.distance)
                        .font(Font.system(size: 23, weight: .light, design: .default))
                        .padding([.bottom, .top], -5)
                }
                VStack(alignment: .center, spacing: 16) {
                    PieSegment(ratio: workoutViewModel.bpmCircleRatio)
                        .fill(workoutViewModel.bpmCircleColor)
                        .frame(width: 23, height: 23, alignment: .center)

                    SunView(sunVisibility: workoutViewModel.sunVisibility)
                        .frame(width: 20, height: 20, alignment: .center)
                        .clipped()
                }


            }

            Spacer()
            HStack {
                Text(workoutViewModel.currentPace)
                    .font(Font.system(size: 20, weight: .light, design: .default))
                Spacer()
                Text(workoutViewModel.averagePace)
                    .font(Font.system(size: 20, weight: .light, design: .default))
            }
        }
        .onAppear(){
            workoutViewModel.startWorkout()
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct WorkoutRunningView_Previews: PreviewProvider {
    
    static var viewModel = WorkoutViewModel(workoutType: WorkoutType(type: .outdoorRunning), workoutService: WorkoutService(), heartZoneService: HeartZoneService())
    
    static var previews: some View {
        WorkoutRunningView(workoutViewModel: viewModel)
    }
}
