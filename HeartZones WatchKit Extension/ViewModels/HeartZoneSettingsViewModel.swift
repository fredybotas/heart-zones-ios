//
//  HeartZoneSettingsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/09/2021.
//

import Foundation
import Combine
import SwiftUI

class HeartZoneSettingsViewModel: ObservableObject {
    // MARK: View
    var heartZoneSettingService: IHeartZoneSettingService
    
    var cancellables = Set<AnyCancellable>()
    //var zones: [HeartZone]
    
    init(heartZoneSettingService: IHeartZoneSettingService) {
        self.heartZoneSettingService = heartZoneSettingService
        
//        self.zones = heartZoneSettingService
        
    }
    

}

