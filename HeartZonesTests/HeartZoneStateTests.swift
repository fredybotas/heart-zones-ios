//
//  HeartZoneStateTests.swift
//  HeartZonesTests
//
//  Created by Michal Manak on 28/07/2021.
//

import Foundation
import XCTest

@testable import HeartZones_WatchKit_Extension

class HeartZoneStateTests: XCTestCase {
    var zoneStateManagerMock: ZoneStateManagerMock!
    var settingsServiceFake: SettingsServiceFake!
    var sut: BaseHeartZoneState!
    
    let maxBpm = 190
    
    override func setUp() {
        self.zoneStateManagerMock = ZoneStateManagerMock()
        self.settingsServiceFake = SettingsServiceFake()
        self.settingsServiceFake.maximumBpm = maxBpm
    }
    
    func getNeighbourZones() -> (HeartZone, HeartZone, HeartZone) {
        let setting = HeartZonesSetting.getDefaultHeartZonesSetting()
        return (setting.zones[0], setting.zones[1], setting.zones[2])
    }
    
    func getTargetZone() -> HeartZone {
        let setting = HeartZonesSetting.getDefaultHeartZonesSetting()
        return setting.zones[2]
    }
    
    func getBpmSampleFromHeartZone(zone: HeartZone) -> Int {
        return zone.getBpmRange(maxBpm: maxBpm).lowerBound + 1
    }
    
    func testHeartZoneStateWithoutActiveZoneSettings() {
        sut = HeartZoneNotAvailableState(stateManager: zoneStateManagerMock, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: 20)
        
        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 0)
    }
    
    func testHeartZoneNotAvailableState() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        sut = HeartZoneNotAvailableState(stateManager: zoneStateManagerMock, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: 20)
        
        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
        XCTAssertNotNil(zoneStateManagerMock.setStateCalledSequence[0].zone)
    }
    
    func testHeartZoneActiveStateChangeZone() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let (zone1, zone2, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone2))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
        XCTAssertEqual(zoneStateManagerMock.setStateCalledSequence[0].zone, zone2)
    }
    
    func testHeartZoneActiveStateSameZone() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 0)
    }
    
    func testHeartZoneActiveStateFromTargetZoneWhenAlertEnabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: targetZone, stateManager: zoneStateManagerMock, movement: .up, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
    func testHeartZoneActiveStateFromTargetZoneWhenAlertDisabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()
        settingsServiceFake.targetHeartZoneAlertEnabled = false
        
        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: targetZone, stateManager: zoneStateManagerMock, movement: .up, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
    func testHeartZoneActiveStateToTargetZoneWhenAlertEnabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: targetZone))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
    func testHeartZoneActiveStateToTargetZoneWhenAlertDisabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()
        settingsServiceFake.targetHeartZoneAlertEnabled = false
        
        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsService: self.settingsServiceFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: targetZone))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
}
