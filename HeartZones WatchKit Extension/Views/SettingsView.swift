//
//  SettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import SwiftUI
import Swinject

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        List {
            Section(header: Text("Heart Zones")) {
                VStack(alignment: .leading) {
                    Text("Max BPM")
                    Picker("Max BPM", selection: $settingsViewModel.maxBpm) {
                        ForEach(SettingsViewModel.kMinimumBpm..<SettingsViewModel.kMaximumBpm + 1) { bpm in
                            Text(String(bpm)).tag(bpm)
                        }
                    }
                    .frame(height: 25)
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                }
                NavigationLink(destination: LazyView(HeartZoneCircularPickerView(heartZoneSettingsViewModel: DIContainer.shared.resolve(HeartZoneSettingsViewModel.self)!))) {
                    Text("Zones settings")
                }
                Picker("Target zone", selection: $settingsViewModel.targetZone) {
                    ForEach(settingsViewModel.zones) { zone in
                        Text(zone.name).tag(zone.id)
                    }
                }
                .frame(height: 40)
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
                Picker("Energy", selection: $settingsViewModel.selectedEnergyMetric) {
                    ForEach(settingsViewModel.energyMetricOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
                Picker("Speed", selection: $settingsViewModel.selectedSpeedMetric) {
                    ForEach(settingsViewModel.speedMetricOptions) { metric in
                        switch metric.type {
                        case .pace:
                            Text("min / " + settingsViewModel.selectedDistanceMetric.type.rawValue).tag(metric)
                        case .speed:
                            Text(settingsViewModel.selectedDistanceMetric.type.rawValue + " / h").tag(metric)
                        }
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
