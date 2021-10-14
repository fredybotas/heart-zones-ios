//
//  HeartZonesSettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 25/09/2021.
//

import SwiftUI

struct HeartZoneSettingPicker: View {
    @Binding var actualBpm: Int
    let minChoosableBpm: Int
    let maxChoosableBpm: Int
    let maximumBpm: Int
    let color: Color
    let position: HorizontalAlignment

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Picker("A", selection: $actualBpm, content: {
                ForEach(minChoosableBpm..<maxChoosableBpm + 1) { bpm in
                    HStack(alignment: .center, spacing: 0) {
                        Text(String(bpm) + "%")
                            .font(Font.system(size: 12, weight: .light, design: .default))
                    }
                    .tag(bpm)
                }
            })
                .focusBorderOverlay(color)
                .pickerStyle(WheelPickerStyle())
                .frame(width: 48, height: 20)
                .labelsHidden()
            
            Text(String(Int((Double(actualBpm) / 100.0) * Double(maximumBpm))) + " BPM")
                .font(Font.system(size: 10, weight: .light, design: .default))
        }
    }
}

struct HeartZoneView: View {
    @ObservedObject var heartZoneViewModel: HeartZoneViewModel
    let maximumBpm: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HeartZoneSettingPicker(actualBpm: $heartZoneViewModel.lowerBound,
                                   minChoosableBpm: 0,
                                   maxChoosableBpm: 100,
                                   maximumBpm: maximumBpm, color: heartZoneViewModel.color, position: .leading)
            Spacer()
            Text(heartZoneViewModel.name)
                .font(Font.system(size: 14, weight: .light, design: .default))
                .frame(width: 50)
            Spacer()
            HeartZoneSettingPicker(actualBpm: $heartZoneViewModel.upperBound,
                                   minChoosableBpm: 0,
                                   maxChoosableBpm: 100,
                                   maximumBpm: maximumBpm, color: heartZoneViewModel.color, position: .trailing)
        }
        .frame(height: 45)
        .background(heartZoneViewModel.color)
        .cornerRadius(6)
        // TODO: Enable coloring when list is here
        // .listRowPlatterColor(color)
    }
}

struct HeartZonesSettingsView: View {
    @ObservedObject var heartZoneSettingsViewModel: HeartZoneSettingsViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(heartZoneSettingsViewModel.zones) { zone in
                HeartZoneView(heartZoneViewModel: zone, maximumBpm: 170)
            }
            .navigationBarTitle("Zone Settings")
        }
    }
}

struct HeartZonesSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        HeartZonesSettingsView(heartZoneSettingsViewModel: HeartZoneSettingsViewModel(settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}

extension Picker {
    func focusBorderOverlay(_ color: Color) -> some View {
        let isWatchOS7: Bool = {
            if #available(watchOS 7, *) {
                return true
            }

            return false
        }()

        let padding: EdgeInsets = {
            if isWatchOS7 {
                return .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            }

            return .init(top: 8.5, leading: 0.5, bottom: 8.5, trailing: 0.5)
        }()

        return self
            .overlay(
                RoundedRectangle(cornerRadius: isWatchOS7 ? 8 : 7)
                    .stroke(color, lineWidth: isWatchOS7 ? 4 : 3.5)
                    .offset(y: isWatchOS7 ? 0 : 8)
                    .padding(padding)
            )
    }
}
