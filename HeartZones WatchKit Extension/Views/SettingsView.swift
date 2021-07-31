//
//  SettingsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 31/07/2021.
//

import SwiftUI

struct SettingsListRow: View {
    let title: String
    @Binding var enabled: Bool
    
    var body: some View {
        HStack {
            Toggle(title, isOn: $enabled)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        List {
            SettingsListRow(title: "Target zone alert", enabled: $settingsViewModel.targetHeartZoneAlertEnabled)
            SettingsListRow(title: "Zone pass alert", enabled: $settingsViewModel.heartZonesAlertEnabled)
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsViewModel: SettingsViewModel(settingsRepository: SettingsRepository()))
    }
}
