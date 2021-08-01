//
//  ZoneStateManagerMock.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 28/07/2021.
//

import Foundation
@testable import HeartZones_WatchKit_Extension

class ZoneStateManagerMock: ZoneStateManager {
    var activeHeartZoneSetting: HeartZonesSetting?
    
    var setStateCalledCount = 0
    var setStateCalledSequence = [BaseHeartZoneState]()
    
    func initializeActiveHeartZoneSetting() {
        activeHeartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting(maximumBpm: 195)
    }
    
    func setState(state: BaseHeartZoneState) {
        setStateCalledCount += 1
        setStateCalledSequence.append(state)
    }
}
