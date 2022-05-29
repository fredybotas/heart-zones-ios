//
//  HeartZoneCircularPickerView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 10/10/2021.
//

import SwiftUI

struct HeartZoneControl: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel
    let radius: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        Circle()
            .trim(
                from:
                CGFloat(heartZoneViewModel.lowerBound) / CGFloat(100),
                to:
                CGFloat(heartZoneViewModel.upperBound) / CGFloat(100)
            )
            .stroke(heartZoneViewModel.color, lineWidth: lineWidth)
            .frame(width: radius * 2, height: radius * 2)
            .rotationEffect(.degrees(-90))
    }
}

struct HeartZoneKnob: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel
    @Binding var focusedIndex: Int
    let index: Int
    let isLast: Bool

    let radius: CGFloat
    let knobRadius: CGFloat

    private let knobPadding: CGFloat = 10

    var body: some View {
        // Knobs
        Circle()
            .fill(focusedIndex == index ? Color.green : Color.white)
            .frame(width: (knobRadius + 1) * 2, height: (knobRadius + 1) * 2)
            .padding(knobPadding)
            .offset(y: -radius)
            .rotationEffect(
                Angle.degrees(Double((CGFloat(heartZoneViewModel.upperBound) / 100) * CGFloat(360)))
            )
        Circle()
            .fill(heartZoneViewModel.color)
            .frame(width: knobRadius * 2, height: knobRadius * 2)
            .padding(knobPadding)
            .offset(y: -radius)
            .rotationEffect(
                Angle.degrees(Double((CGFloat(heartZoneViewModel.upperBound) / 100) * CGFloat(360)))
            )
            .focusable(true) { focused in
                if focused {
                    focusedIndex = index
                }
            }
            .digitalCrownRotation(
                $heartZoneViewModel.crown, from: Double(heartZoneViewModel.minBound),
                through: Double(heartZoneViewModel.maxBound), by: 1.0, sensitivity: .medium,
                isContinuous: false, isHapticFeedbackEnabled: false
            )
    }
}

struct MiddleTextView: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel
    let maxBpm: Int

    var maxScreenSize: (Int, Int) = widthToMaxSize(width: WKInterfaceDevice.current().screenBounds.width)

    func getDeviceSizeMultiplier() -> CGFloat {
        let screenSize = maxScreenSize
        return CGFloat(screenSize.0) / kSmallestDeviceWidth
    }

    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            Text(heartZoneViewModel.name)
                .font(Font.system(size: 16 * getDeviceSizeMultiplier(), weight: .medium, design: .default))
            HStack(alignment: .center, spacing: 0) {
                VStack {
                    Text("\(heartZoneViewModel.lowerBound)")
                        .font(
                            Font.system(size: 14 * getDeviceSizeMultiplier(), weight: .light, design: .default)
                        )
                        .frame(width: 25 * getDeviceSizeMultiplier(), alignment: .trailing)
                    Text("\(Int((Double(heartZoneViewModel.lowerBound) / 100.0) * Double(maxBpm)))")
                        .font(
                            Font.system(size: 14 * getDeviceSizeMultiplier(), weight: .light, design: .default)
                        )
                        .frame(width: 25 * getDeviceSizeMultiplier(), alignment: .trailing)
                }
                VStack {
                    Text("-")
                        .font(
                            Font.system(size: 12 * getDeviceSizeMultiplier(), weight: .light, design: .default)
                        )
                        .frame(width: 12 * getDeviceSizeMultiplier())
                    Text("-")
                        .font(
                            Font.system(size: 12 * getDeviceSizeMultiplier(), weight: .light, design: .default)
                        )
                        .frame(width: 12 * getDeviceSizeMultiplier())
                }
                VStack {
                    Text("\(heartZoneViewModel.upperBound)")
                        .font(
                            Font.system(size: 14 * getDeviceSizeMultiplier(), weight: .light, design: .default)
                        )
                        .frame(width: 25 * getDeviceSizeMultiplier(), alignment: .leading)
                    Text("\(Int((Double(heartZoneViewModel.upperBound) / 100.0) * Double(maxBpm)))")
                        .font(
                            Font.system(size: 14 * getDeviceSizeMultiplier(), weight: .light, design: .default)
                        )
                        .frame(width: 25 * getDeviceSizeMultiplier(), alignment: .leading)
                }
                VStack(alignment: .leading) {
                    Text("%")
                        .frame(height: 14 * getDeviceSizeMultiplier(), alignment: .bottomLeading)
                        .font(
                            Font.system(size: 8 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                    Text("BPM")
                        .frame(height: 14 * getDeviceSizeMultiplier(), alignment: .bottomLeading)
                        .font(
                            Font.system(size: 8 * getDeviceSizeMultiplier(), weight: .light, design: .default))
                }
            }
        }
        .offset(x: 0, y: -2)
    }
}

struct HeartZoneCircularPickerView: View {
    @ObservedObject var heartZoneSettingsViewModel: HeartZoneSettingsViewModel
    @State var focusedIndex: Int = 0
    private let kKnobHelperSize: CGFloat = 25

    func getMinDimension(geo: GeometryProxy) -> CGFloat {
        let width = geo.size.width
        let height = geo.size.height

        return width < height ? width : height
    }

    func getRadius(geo: GeometryProxy) -> CGFloat {
        let min = getMinDimension(geo: geo)
        let maxRadius = min / 2
        return maxRadius - 12
    }

    func getLineWidth(geo: GeometryProxy) -> CGFloat {
        return getMinDimension(geo: geo) / 25
    }

    func getKnobRadius(geo: GeometryProxy) -> CGFloat {
        return getMinDimension(geo: geo) / 19
    }
    
    var knobDrag: some Gesture {
        DragGesture()
            .onChanged { _ in
                heartZoneSettingsViewModel.knobDragStarted()
            }
            .onEnded { _ in
                heartZoneSettingsViewModel.knobDragEnded()
            }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                ForEach(0 ..< heartZoneSettingsViewModel.zones.count) { i in
                    HeartZoneControl(
                        heartZoneViewModel: heartZoneSettingsViewModel.zones[i], radius: getRadius(geo: geo),
                        lineWidth: getLineWidth(geo: geo)
                    )
                }

                ForEach(0 ..< heartZoneSettingsViewModel.zones.count) { i in
                    HeartZoneKnob(
                        heartZoneViewModel: heartZoneSettingsViewModel.zones[i], focusedIndex: $focusedIndex,
                        index: i, isLast: heartZoneSettingsViewModel.zones[i].isLast,
                        radius: getRadius(geo: geo), knobRadius: getKnobRadius(geo: geo)
                    )
                    .gesture(knobDrag)
                }
                
                if heartZoneSettingsViewModel.showCrownHelper {
                    Image(systemName: "digitalcrown.arrow.counterclockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: kKnobHelperSize, alignment: .center)
                        .position(x: geo.size.width - kKnobHelperSize / 2, y: kKnobHelperSize / 2)
                }

                MiddleTextView(
                    heartZoneViewModel: heartZoneSettingsViewModel.zones[focusedIndex],
                    maxBpm: heartZoneSettingsViewModel.settingsService.maximumBpm
                )
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .navigationBarTitle("Zone Settings")
    }
}

struct HeartZoneCircularPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HeartZoneCircularPickerView(
                heartZoneSettingsViewModel: HeartZoneSettingsViewModel(
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    ))
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 3 - 38mm"))
            .previewDisplayName("38mm")
            HeartZoneCircularPickerView(
                heartZoneSettingsViewModel: HeartZoneSettingsViewModel(
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    ))
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 3 - 42mm"))
            .previewDisplayName("42mm")
            HeartZoneCircularPickerView(
                heartZoneSettingsViewModel: HeartZoneSettingsViewModel(
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    ))
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
            .previewDisplayName("40mm")
            HeartZoneCircularPickerView(
                heartZoneSettingsViewModel: HeartZoneSettingsViewModel(
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    ))
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))
            .previewDisplayName("44mm")
            HeartZoneCircularPickerView(
                heartZoneSettingsViewModel: HeartZoneSettingsViewModel(
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    ))
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 41mm"))
            .previewDisplayName("41mm")
            HeartZoneCircularPickerView(
                heartZoneSettingsViewModel: HeartZoneSettingsViewModel(
                    settingsService: SettingsService(
                        settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                    ))
            )
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
            .previewDisplayName("45mm")
        }
    }
}
