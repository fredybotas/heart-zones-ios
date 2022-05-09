//
//  SettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import SwiftUI
import Swinject

struct PickerView<T: Hashable & Identifiable & CustomStringConvertible>: View {
    let possibleValues: [T]
    var selectionId: Binding<Int>?
    var selectionType: Binding<T>?

    @Binding var showView: Bool

    var body: some View {
        List {
            ForEach(possibleValues) { element in
                ZStack(alignment: .trailing) {
                    Button(
                        element.description,
                        action: {
                            selectionId?.wrappedValue = element.id as? Int ?? 0
                            selectionType?.wrappedValue = element
                            showView = false
                        }
                    )
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

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var selectionShownMaxBpm = false
    @State var selectionShownZonesCount = false
    @State var selectionShownTargetZone = false
    @State var selectionShownDistanceMetricOptions = false
    @State var selectionShownEnergyMetricOptions = false
    @State var selectionShownSpeedMetricOptions = false
    @State var selectionShownFieldOne = false
    @State var selectionShownFieldTwo = false

    func getSpeedString(speedMetric: SpeedMetric, distanceMetric: DistanceMetric) -> String {
        switch speedMetric.type {
        case .pace:
            return String("min / " + distanceMetric.type.rawValue)
        case .speed:
            return String(distanceMetric.type.rawValue + " / h")
        }
    }

    var body: some View {
        List {
            Section(header: Text("Heart Zones")) {
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Max BPM", selection: $settingsViewModel.maxBpm) {
                        ForEach(settingsViewModel.maxBpmOptions) { bpm in
                            Text(String(bpm.value)).tag(bpm.id)
                        }
                    }
                    .frame(height: 25)
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.maxBpmOptions,
                                selectionId: $settingsViewModel.maxBpm, showView: $selectionShownMaxBpm
                            )),
                        isActive: $selectionShownMaxBpm
                    ) {
                        VStack(alignment: .leading) {
                            Text("Max BPM")
                            Text(String(settingsViewModel.maxBpm))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Zone count", selection: $settingsViewModel.zonesCount) {
                        ForEach(settingsViewModel.zonesCountOptions) { count in
                            Text(String(count.value)).tag(count.id)
                        }
                    }
                    .frame(height: 25)
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.zonesCountOptions,
                                selectionId: $settingsViewModel.zonesCount,
                                showView: $selectionShownZonesCount
                            )), isActive: $selectionShownZonesCount
                    ) {
                        VStack(alignment: .leading) {
                            Text("Zone count")
                            Text(String(settingsViewModel.zonesCount))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }

                NavigationLink(
                    destination: LazyView(
                        HeartZoneCircularPickerView(
                            heartZoneSettingsViewModel: DIContainer.shared.resolve(
                                HeartZoneSettingsViewModel.self)!))
                ) {
                    Text("Zone settings")
                }
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Target zone", selection: $settingsViewModel.targetZone) {
                        ForEach(settingsViewModel.zones) { zone in
                            Text(zone.name).tag(zone.id)
                        }
                    }
                    .frame(height: 40)
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.zones, selectionId: $settingsViewModel.targetZone,
                                showView: $selectionShownTargetZone
                            )), isActive: $selectionShownTargetZone
                    ) {
                        VStack(alignment: .leading) {
                            Text("Target zone")
                            // TODO: Not safe, fix if zone id changes
                            Text(String(settingsViewModel.zones[settingsViewModel.targetZone].name))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Section(header: Text("Alert Settings")) {
                Toggle("Target zone alert", isOn: $settingsViewModel.targetHeartZoneAlertEnabled)
                Toggle("Zone pass alert", isOn: $settingsViewModel.heartZonesAlertEnabled)
            }
            Section(header: Text("Units")) {
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Distance", selection: $settingsViewModel.selectedDistanceMetric) {
                        ForEach(settingsViewModel.distanceMetricOptions) { metric in
                            Text(metric.type.rawValue).tag(metric)
                        }
                    }
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.distanceMetricOptions,
                                selectionType: $settingsViewModel.selectedDistanceMetric,
                                showView: $selectionShownDistanceMetricOptions
                            )),
                        isActive: $selectionShownDistanceMetricOptions
                    ) {
                        VStack(alignment: .leading) {
                            Text("Distance")
                            Text(String(settingsViewModel.selectedDistanceMetric.description))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Energy", selection: $settingsViewModel.selectedEnergyMetric) {
                        ForEach(settingsViewModel.energyMetricOptions) { metric in
                            Text(metric.type.rawValue).tag(metric)
                        }
                    }
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.energyMetricOptions,
                                selectionType: $settingsViewModel.selectedEnergyMetric,
                                showView: $selectionShownEnergyMetricOptions
                            )),
                        isActive: $selectionShownEnergyMetricOptions
                    ) {
                        VStack(alignment: .leading) {
                            Text("Energy")
                            Text(String(settingsViewModel.selectedEnergyMetric.description))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Speed", selection: $settingsViewModel.selectedSpeedMetric) {
                        ForEach(settingsViewModel.speedMetricOptions) { metric in
                            Text(
                                getSpeedString(
                                    speedMetric: metric, distanceMetric: settingsViewModel.selectedDistanceMetric
                                )
                            ).tag(metric)
                        }
                    }
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.speedMetricOptions,
                                selectionType: $settingsViewModel.selectedSpeedMetric,
                                showView: $selectionShownSpeedMetricOptions
                            )),
                        isActive: $selectionShownSpeedMetricOptions
                    ) {
                        VStack(alignment: .leading) {
                            Text("Speed")
                            Text(
                                String(
                                    getSpeedString(
                                        speedMetric: settingsViewModel.selectedSpeedMetric,
                                        distanceMetric: settingsViewModel.selectedDistanceMetric
                                    ))
                            )
                            .font(Font.footnote)
                            .foregroundColor(.gray)
                        }
                    }
                }
            }

            Section(header: Text("Metrics")) {
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Field 1", selection: $settingsViewModel.selectedMetricInFieldOne) {
                        ForEach(settingsViewModel.metricInFieldOneOptions) { metric in
                            Text(metric.type.rawValue).tag(metric)
                        }
                    }
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.metricInFieldOneOptions,
                                selectionType: $settingsViewModel.selectedMetricInFieldOne,
                                showView: $selectionShownFieldOne
                            )), isActive: $selectionShownFieldOne
                    ) {
                        VStack(alignment: .leading) {
                            Text("Field 1")
                            Text(String(settingsViewModel.selectedMetricInFieldOne.description))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if #available(watchOSApplicationExtension 7.0, *) {
                    Picker("Field 2", selection: $settingsViewModel.selectedMetricInFieldTwo) {
                        ForEach(settingsViewModel.metricInFieldTwoOptions) { metric in
                            Text(metric.type.rawValue).tag(metric)
                        }
                    }
                } else {
                    NavigationLink(
                        destination: LazyView(
                            PickerView(
                                possibleValues: settingsViewModel.metricInFieldTwoOptions,
                                selectionType: $settingsViewModel.selectedMetricInFieldTwo,
                                showView: $selectionShownFieldTwo
                            )), isActive: $selectionShownFieldTwo
                    ) {
                        VStack(alignment: .leading) {
                            Text("Field 2")
                            Text(String(settingsViewModel.selectedMetricInFieldTwo.description))
                                .font(Font.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            Section(header: Text("Misc")) {
                Button(action: {
                    settingsViewModel.resetHeartZoneSettings()
                }, label: {
                    Text("Reset Heart Zone Settings")
                })
                .accentColor(.red)
                Button(action: {
                    settingsViewModel.resetWorkoutsOrder()
                }, label: {
                    Text("Reset Workouts Order")
                })
                .accentColor(.red)
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            settingsViewModel: SettingsViewModel(
                settingsService: SettingsService(
                    settingsRepository: SettingsRepository(), healthKitService: HealthKitService()
                )))
    }
}
