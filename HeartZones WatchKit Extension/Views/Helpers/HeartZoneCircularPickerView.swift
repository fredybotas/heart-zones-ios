//
//  HeartZoneCircularPickerView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 10/10/2021.
//

import SwiftUI

struct HeartZoneControl: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel

    var body: some View {
        Circle()
            .trim(from:
                    CGFloat(heartZoneViewModel.lowerBound) / CGFloat(100)
                  , to:
                    CGFloat(heartZoneViewModel.upperBound) / CGFloat(100)
            )
            .stroke(heartZoneViewModel.color, lineWidth: 5)
            .frame(width: 60 * 2, height: 60 * 2)
            .rotationEffect(.degrees(-90))
    }
}

struct HeartZoneKnob: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel
    @Binding var focusedIndex: Int
    let fixed: Bool
    let index: Int
    
    private let radius: CGFloat = 7
    private let knobPadding: CGFloat = 10
        
    var body: some View {
        // Knobs
        Circle()
            .fill(focusedIndex == index ? Color.green : Color.white)
            .frame(width: (radius + 1) * 2, height: (radius + 1) * 2)
            .padding(knobPadding)
            .offset(y: -60)
            .rotationEffect(
                Angle.degrees(Double((CGFloat(heartZoneViewModel.upperBound) / 100) * CGFloat(360)))
            )
            
        Circle()
            .fill(heartZoneViewModel.color)
            .frame(width: radius * 2, height: radius * 2)
            .padding(knobPadding)
            .offset(y: -60)
            .rotationEffect(
                Angle.degrees(Double((CGFloat(heartZoneViewModel.upperBound) / 100) * CGFloat(360)))
            )
            .focusable()
            .digitalCrownRotation($heartZoneViewModel.crown, from: Double(heartZoneViewModel.minBound), through: Double(heartZoneViewModel.maxBound), by: 1.0, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: false)
            .gesture(DragGesture(minimumDistance: 0.0)
            .onChanged({ value in
                focusedIndex = index
                if fixed { return }
                self.change(value.location)
            }))
    }
    
    private func change(_ location: CGPoint) {
        // creating vector from location point
        let vector = CGVector(dx: location.x, dy: location.y)
        
        // geting angle in radian need to subtract the knob radius and padding
        let angle = atan2(vector.dy - (radius + knobPadding), vector.dx - (radius + knobPadding)) + .pi/2.0
        
        // convert angle range from (-pi to pi) to (0 to 2pi)
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let degrees = fixedAngle * 180 / .pi
        let upperBound = Int((degrees / 360.0) * 100.0)
        if heartZoneViewModel.maxBound >= upperBound && heartZoneViewModel.minBound <= upperBound {
            heartZoneViewModel.upperBound = upperBound
        }
    }
}

struct MiddleTextView: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel
    let maxBpm: Int
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(heartZoneViewModel.name)
            HStack(alignment: .center, spacing: 0) {
                VStack {
                    Text("\(heartZoneViewModel.lowerBound)")
                        .font(Font.system(size: 12, weight: .medium, design: .default))
                        .frame(width: 24, alignment: .trailing)
                    Text("\(Int((Double(heartZoneViewModel.lowerBound) / 100.0) * Double(maxBpm)))")
                        .font(Font.system(size: 12, weight: .medium, design: .default))
                        .frame(width: 24, alignment: .trailing)
                }
                VStack {
                    Text("-")
                        .font(Font.system(size: 12, weight: .medium, design: .default))
                        .frame(width: 12)
                    Text("-")
                        .font(Font.system(size: 12, weight: .medium, design: .default))
                        .frame(width: 12)
                }
                VStack {
                    Text("\(heartZoneViewModel.upperBound)")
                        .font(Font.system(size: 12, weight: .medium, design: .default))
                        .frame(width: 24, alignment: .leading)
                    Text("\(Int((Double(heartZoneViewModel.upperBound) / 100.0) * Double(maxBpm)))")
                        .font(Font.system(size: 12, weight: .medium, design: .default))
                        .frame(width: 24, alignment: .leading)
                }
                VStack {
                    Text("%")
                        .frame(width: 20, height: 12, alignment: .bottomLeading)
                        .font(Font.system(size: 8, weight: .medium, design: .default))
                    Text("BPM")
                        .frame(width: 20, height: 12, alignment: .bottomLeading)
                        .font(Font.system(size: 8, weight: .medium, design: .default))
                }
            }
        }
    }
}

struct BackgroundCircle: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 57 * 2, height: 57 * 2)
    }
}

struct HeartZoneCircularPickerView: View {
    @ObservedObject var heartZoneSettingsViewModel: HeartZoneSettingsViewModel
    @State var focusedIndex: Int = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<heartZoneSettingsViewModel.zones.count) { i in
                HeartZoneControl(heartZoneViewModel: heartZoneSettingsViewModel.zones[i])
            }
//            BackgroundCircle(color: heartZoneSettingsViewModel.zones[focusedIndex].color)

            ForEach(0..<heartZoneSettingsViewModel.zones.count) { i in
                HeartZoneKnob(heartZoneViewModel: heartZoneSettingsViewModel.zones[i], focusedIndex: $focusedIndex, fixed: i == heartZoneSettingsViewModel.zones.count - 1, index: i)
            }
            
            MiddleTextView(heartZoneViewModel: heartZoneSettingsViewModel.zones[focusedIndex], maxBpm: heartZoneSettingsViewModel.settingsService.maximumBpm)
        }
        .offset(x: 0, y: 5)
        .navigationBarTitle("Zone Settings")
    }
}

struct HeartZoneCircularPickerView_Previews: PreviewProvider {
    static var previews: some View {
        HeartZoneCircularPickerView(heartZoneSettingsViewModel: HeartZoneSettingsViewModel(settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}
