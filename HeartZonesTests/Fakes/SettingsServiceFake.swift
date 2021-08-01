//
//  SettingsServiceFake.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 01/08/2021.
//

import Foundation

@testable import HeartZones_WatchKit_Extension

class SettingsServiceFake: ISettingsService {
    var heartZonesAlertEnabled: Bool = true
    var targetHeartZoneAlertEnabled: Bool = true
    var maximumBpm: Int = 195
}
