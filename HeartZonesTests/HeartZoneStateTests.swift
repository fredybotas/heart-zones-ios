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
    var settingsRepositoryFake: SettingsRepositoryFake!
    var sut: BaseHeartZoneState!
    
    override func setUp() {
        self.zoneStateManagerMock = ZoneStateManagerMock()
        self.settingsRepositoryFake = SettingsRepositoryFake()
    }
    
    func getNeighbourZones() -> (HeartZone, HeartZone, HeartZone) {
        let setting = HeartZonesSetting.getDefaultHeartZonesSetting(age: 25)
        return (setting.zones[0], setting.zones[1], setting.zones[2])
    }
    
    func getTargetZone() -> HeartZone {
        let setting = HeartZonesSetting.getDefaultHeartZonesSetting(age: 25)
        return setting.zones[2]
    }
    
    func getBpmSampleFromHeartZone(zone: HeartZone) -> Int {
        return zone.bpmRange.lowerBound + 1
    }
    
    func testHeartZoneStateWithoutActiveZoneSettings() {
        sut = HeartZoneNotAvailableState(stateManager: zoneStateManagerMock, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: 20)
        
        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 0)
    }
    
    func testHeartZoneNotAvailableState() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        sut = HeartZoneNotAvailableState(stateManager: zoneStateManagerMock, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: 20)
        
        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
        XCTAssertNotNil(zoneStateManagerMock.setStateCalledSequence[0].zone)
    }
    
    func testHeartZoneNotAvailableStateNotValidZone() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        sut = HeartZoneNotAvailableState(stateManager: zoneStateManagerMock, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: -20)
        
        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 0)
    }
    
    func testHeartZoneActiveStateChangeZone() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let (zone1, zone2, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone2))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
        XCTAssertEqual(zoneStateManagerMock.setStateCalledSequence[0].zone, zone2)
    }
    
    func testHeartZoneActiveStateSameZone() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 0)
    }
    
    func testHeartZoneActiveStateFromTargetZoneWhenAlertEnabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: targetZone, stateManager: zoneStateManagerMock, movement: .up, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
    func testHeartZoneActiveStateFromTargetZoneWhenAlertDisabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()
        settingsRepositoryFake.targetHeartZoneAlertEnabled = false
        
        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: targetZone, stateManager: zoneStateManagerMock, movement: .up, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: zone1))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
    func testHeartZoneActiveStateToTargetZoneWhenAlertEnabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()

        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: targetZone))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
    func testHeartZoneActiveStateToTargetZoneWhenAlertDisabled() {
        zoneStateManagerMock.initializeActiveHeartZoneSetting()
        settingsRepositoryFake.targetHeartZoneAlertEnabled = false
        
        let targetZone = getTargetZone()
        let (zone1, _, _) = getNeighbourZones()
        sut = HeartZoneActiveState(zone: zone1, stateManager: zoneStateManagerMock, movement: .up, settingsRepository: self.settingsRepositoryFake)
        sut.bpmChanged(bpm: getBpmSampleFromHeartZone(zone: targetZone))

        XCTAssertEqual(zoneStateManagerMock.setStateCalledCount, 1)
    }
    
}
