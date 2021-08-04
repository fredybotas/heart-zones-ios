//
//  SettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        List {
            Section(header: Text("Zones")) {
                NavigationLink(destination: SettingsView(settingsViewModel: settingsViewModel)) {
                    Text("Zones")
                }
                Picker("Max BPM", selection: $settingsViewModel.maxBpm) {
                    ForEach(SettingsViewModel.kMinimumBpm..<SettingsViewModel.kMaximumBpm + 1) { bpm in
                        Text(String(bpm)).tag(bpm)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 35)
            }

            Section(header: Text("Alert Settings")) {
                Toggle("Target zone alert", isOn: $settingsViewModel.targetHeartZoneAlertEnabled)
                Toggle("Zone pass alert", isOn: $settingsViewModel.heartZonesAlertEnabled)
            }
            Section(header: Text("Units")) {
                Picker("Distance", selection: $settingsViewModel.selectedDistanceMetric) {
                    ForEach(settingsViewModel.distanceMetricOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
            }
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: SettingsViewModel(settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}
