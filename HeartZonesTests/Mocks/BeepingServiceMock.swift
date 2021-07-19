//
//  BeepingServiceMock.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 19/07/2021.
//

import Foundation
@testable import HeartZones_WatchKit_Extension

class BeepingServiceMock: IBeepingService {
    var stopBeepingCalledCount = 0
    var handleDeviceBeepCallSequence = [(HeartZonesSetting.HeartZoneMovement, Bool, Bool)]()
    
    func handleDeviceBeep(heartZoneMovement: HeartZonesSetting.HeartZoneMovement, fromTargetZone: Bool, enteredTargetZone: Bool) {
        handleDeviceBeepCallSequence.append((heartZoneMovement, fromTargetZone, enteredTargetZone))
    }
    
    func stopAnyBeeping() {
        stopBeepingCalledCount += 1
    }
}
