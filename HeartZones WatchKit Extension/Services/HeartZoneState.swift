//
//  HeartZoneState.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 28/07/2021.
//

import Foundation

let kZoneChangeThreshold = 2

protocol ZoneStateManager {
    var activeHeartZoneSetting: HeartZonesSetting? { get }

    func setState(state: BaseHeartZoneState)
}

class BaseHeartZoneState {
    fileprivate let stateManager: ZoneStateManager
    fileprivate var settingsService: ISettingsService

    fileprivate(set) var movement: HeartZonesSetting.HeartZoneMovement
    fileprivate(set) var zone: HeartZone?

    // swiftformat:disable:next redundantFileprivate
    fileprivate init(
        stateManager: ZoneStateManager, movement: HeartZonesSetting.HeartZoneMovement,
        settingsService: ISettingsService
    ) {
        self.stateManager = stateManager
        self.movement = movement
        self.settingsService = settingsService
    }

    fileprivate func getNewZoneAndMovement(currentZone: HeartZone?, bpm: Int) -> (
        HeartZonesSetting.HeartZoneMovement, HeartZone?
    ) {
        guard let activeHeartZoneSetting = stateManager.activeHeartZoneSetting else {
            return (.undefined, nil)
        }
        return activeHeartZoneSetting.evaluateBpmChange(
            currentZone: currentZone, bpm: bpm, maxBpm: settingsService.maximumBpm
        )
    }

    func bpmChanged(bpm _: Int) {}
}

class HeartZoneNotAvailableState: BaseHeartZoneState {
    init(stateManager: ZoneStateManager, settingsService: ISettingsService) {
        super.init(stateManager: stateManager, movement: .undefined, settingsService: settingsService)
    }

    override func bpmChanged(bpm: Int) {
        let (_, zone) = getNewZoneAndMovement(currentZone: nil, bpm: bpm)
        guard let zone = zone else { return }

        stateManager.setState(
            state: HeartZoneActiveState(
                zone: zone, stateManager: stateManager, movement: .undefined,
                settingsService: settingsService
            ))
    }
}

class HeartZoneActiveState: BaseHeartZoneState {
    private var sameZonesContainer = SameElementsContainer<HeartZone>()
    init(
        zone: HeartZone, stateManager: ZoneStateManager, movement: HeartZonesSetting.HeartZoneMovement,
        settingsService: ISettingsService
    ) {
        super.init(stateManager: stateManager, movement: movement, settingsService: settingsService)

        self.zone = zone
    }

    private func shouldChangeZone() -> Bool {
        if zone?.target ?? false, settingsService.targetHeartZoneAlertEnabled {
            return sameZonesContainer.count >= kZoneChangeThreshold
        }
        return true
    }

    override func bpmChanged(bpm: Int) {
        let (movement, zone) = getNewZoneAndMovement(currentZone: self.zone, bpm: bpm)
        if movement == .stay {
            sameZonesContainer.removeAll()
        }
        guard let zone = zone else { return }

        sameZonesContainer.RefreshAndInsert(element: zone)

        if shouldChangeZone() {
            stateManager.setState(
                state: HeartZoneActiveState(
                    zone: zone, stateManager: stateManager, movement: movement,
                    settingsService: settingsService
                ))
        }
    }
}
