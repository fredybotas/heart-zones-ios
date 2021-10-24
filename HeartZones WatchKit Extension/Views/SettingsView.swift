//
//  SettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import SwiftUI
import Swinject
import XCTest

struct PickerView<T: Hashable & Identifiable & CustomStringConvertible>: View {
    let possibleValues: [T]
    var selectionId: Binding<Int>?
    var selectionType: Binding<T>?
    
    @Binding var showView : Bool

    var body: some View {
        List {
            ForEach(possibleValues) { element in
                ZStack(alignment: .trailing) {
                    Button(element.description, action: {
                        selectionId?.wrappedValue = element.id as? Int ?? 0
                        selectionType?.wrappedValue = element
                        showView = false
                    })
                    if let selectionId = selectionId, selectionId.wrappedValue == (element.id as? Int) {
                        Image(systemName: "checkmark")
                    } else if let selectionType = selectionType, selectionType.wrappedValue == element {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        
    }
}

struct BpmDTO: Identifiable, Hashable, CustomStringConvertible {
    var id: Int
    var value: Int
    var description: String { get { String(value) } }
}

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var selectionShown = false
    var body: some View {
        List {
            Section(header: Text("Heart Zones")) {
                VStack(alignment: .leading) {
                    Picker("Max BPM", selection: $settingsViewModel.maxBpm) {
                        ForEach(SettingsViewModel.kMinimumBpm..<SettingsViewModel.kMaximumBpm + 1) { bpm in
                            Text(String(bpm)).tag(bpm)
                        }
                    }
                    .frame(height: 25)
//                    NavigationLink(destination: LazyView(PickerView(possibleValues: [1, 2, 3, 4].map { BpmDTO(id: $0, value: $0) }, selectionId: $settingsViewModel.maxBpm, showView: $selectionShown)), isActive: $selectionShown) {
//                        VStack(alignment: .leading) {
//                            Text("Max BPM")
//                            Text(String(settingsViewModel.maxBpm))
//                                .font(Font.footnote)
//                                .foregroundColor(.gray)
//
//                        }
//                    }
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

            Section(header: Text("Metrics")) {
                Picker("Field 1", selection: $settingsViewModel.selectedMetricInFieldOne) {
                    ForEach(settingsViewModel.metricInFieldOneOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
                Picker("Field 2", selection: $settingsViewModel.selectedMetricInFieldTwo) {
                    ForEach(settingsViewModel.metricInFieldTwoOptions) { metric in
                        Text(metric.type.rawValue).tag(metric)
                    }
                }
            }
            
            Section(header: Text("Misc")) {
                Button(action: { settingsViewModel.resetHeartZoneSettings() }) {
                    Text("Reset Zone Settings")
                }
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: SettingsViewModel(settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}
