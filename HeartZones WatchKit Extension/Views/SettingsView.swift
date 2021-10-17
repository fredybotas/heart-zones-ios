//
//  SettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import SwiftUI
import Swinject
import XCTest

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        List {
            Section(header: Text("Heart Zones")) {
                VStack(alignment: .leading) {
                    if #available(watchOSApplicationExtension 7.0, *) {
                        Text("Max BPM")
                    }
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
                .pickerStyle(DefaultPickerStyle())
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
                .pickerStyle(DefaultPickerStyle())
                Picker("Energy", selection: $settingsViewModel.selectedEnergyMetric) {
                    ForEach(settingsViewModel.energyMetricOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
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
                .pickerStyle(DefaultPickerStyle())
            }
            
            Section(header: Text("Metrics")) {
                Picker("Field 1", selection: $settingsViewModel.selectedMetricInFieldOne) {
                    ForEach(settingsViewModel.metricInFieldOneOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                Picker("Field 2", selection: $settingsViewModel.selectedMetricInFieldTwo) {
                    ForEach(settingsViewModel.metricInFieldTwoOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }
            
            Section(header: Text("Misc")) {
                Button(action: { settingsViewModel.resetHeartZoneSettings() }) {
                    Text("Reset Zone Settings")
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: SettingsViewModel(settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}
