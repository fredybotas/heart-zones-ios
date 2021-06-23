//
//  HeartZonesApp.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 23/06/2021.
//

import SwiftUI

@main
struct HeartZonesApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
