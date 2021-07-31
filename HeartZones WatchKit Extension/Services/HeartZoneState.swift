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

    func setState(state: BaseHeartZoneState);
}

class BaseHeartZoneState {
    fileprivate let stateManager: ZoneStateManager
    fileprivate var settingsRepository: ISettingsRepository

    fileprivate(set) var movement: HeartZonesSetting.HeartZoneMovement
    fileprivate(set) var zone: HeartZone?

    fileprivate init(stateManager: ZoneStateManager, movement: HeartZonesSetting.HeartZoneMovement, settingsRepository: ISettingsRepository) {
        self.stateManager = stateManager
        self.movement = movement
        self.settingsRepository = settingsRepository
    }
    
    fileprivate func getNewZoneAndMovement(currentZone: HeartZone?, bpm: Int) -> (HeartZonesSetting.HeartZoneMovement, HeartZone?) {
        guard let activeHeartZoneSetting = self.stateManager.activeHeartZoneSetting else {
            return (.undefined, nil)
        }
        return activeHeartZoneSetting.evaluateBpmChange(currentZone: currentZone, bpm: bpm)
    }
    
    func bpmChanged(bpm: Int) {}
}

class HeartZoneNotAvailableState: BaseHeartZoneState {
    init(stateManager: ZoneStateManager, settingsRepository: ISettingsRepository) {
        super.init(stateManager: stateManager, movement: .undefined, settingsRepository: settingsRepository)
    }
    
    override func bpmChanged(bpm: Int) {
        let (_, zone) = getNewZoneAndMovement(currentZone: nil, bpm: bpm)
        guard let zone = zone else { return }
        
        self.stateManager.setState(state: HeartZoneActiveState(zone: zone, stateManager: self.stateManager, movement: .undefined, settingsRepository: self.settingsRepository))
    }
}

class HeartZoneActiveState: BaseHeartZoneState {
    
    private var sameZonesContainer = SameElementsContainer<HeartZone>()
    init(zone: HeartZone, stateManager: ZoneStateManager, movement: HeartZonesSetting.HeartZoneMovement, settingsRepository: ISettingsRepository) {
        super.init(stateManager: stateManager, movement: movement, settingsRepository: settingsRepository)

        self.zone = zone        
    }

    private func shouldChangeZone() -> Bool {
        if self.zone?.target ?? false && self.settingsRepository.targetHeartZoneAlertEnabled {
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
        
        self.sameZonesContainer.RefreshAndInsert(element: zone)
        
        if shouldChangeZone() {
            self.stateManager.setState(state: HeartZoneActiveState(zone: zone, stateManager: self.stateManager, movement: movement, settingsRepository: self.settingsRepository))
        }
    }
}
