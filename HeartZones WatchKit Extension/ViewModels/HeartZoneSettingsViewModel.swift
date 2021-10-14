//
//  HeartZoneSettingsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/09/2021.
//

import Foundation
import Combine
import SwiftUI

class HeartZoneViewModel: ObservableObject, Identifiable {
    let zone: HeartZone

    @Published var lowerBound: Int
    @Published var upperBound: Int
    
    @Published var minBound: Int
    @Published var maxBound: Int

    @Published var crown: Double
    
    var color: Color
    var name: String
    
    var cancellables = Set<AnyCancellable>()
    
    init(zone: HeartZone) {
        self.zone = zone
        self.lowerBound = zone.bpmRangePercentage.lowerBound
        self.upperBound = zone.bpmRangePercentage.upperBound
                
        self.minBound = 0
        self.maxBound = 100
        
        self.color = zone.color.toColor()
        self.name = zone.name
        
        self.crown = Double(zone.bpmRangePercentage.upperBound)
        self.$crown
            .removeDuplicates()
            .sink(receiveValue: { val in
                self.upperBound = Int(val)
            })
            .store(in: &cancellables)
        
        self.$upperBound
            .removeDuplicates()
            .map( { Double($0) } )
            .sink { [weak self] val in
                self?.crown = val
            }
            .store(in: &cancellables)
    }
    
    func getHeartZone() -> HeartZone {
        return HeartZone(id: zone.id, name: zone.name, bpmRangePercentage: lowerBound...upperBound, color: zone.color, target: zone.target)
    }
    
    func setBounds(prevZone: HeartZoneViewModel?, nextZone: HeartZoneViewModel?) {
        if let prevZone = prevZone {
            prevZone
                .$upperBound
                .removeDuplicates()
                .sink(receiveValue: { [weak self] val in
                    self?.lowerBound = val
                    self?.minBound = val
                })
                .store(in: &cancellables)
        }
        if let nextZone = nextZone {
            nextZone
                .$lowerBound
                .removeDuplicates()
                .sink(receiveValue: { [weak self] val in
                    self?.upperBound = val
                })
                .store(in: &cancellables)
            nextZone
                .$upperBound
                .removeDuplicates()
                .sink(receiveValue: { [weak self] val in
                    self?.maxBound = val
                })
                .store(in: &cancellables)
        }
    }
}

class HeartZoneSettingsViewModel: ObservableObject {
    var settingsService: ISettingsService

    @Published var zones: [HeartZoneViewModel]

    var cancellables = Set<AnyCancellable>()
    let zoneSetting: HeartZonesSetting
    
    init(settingsService: ISettingsService) {
        self.settingsService = settingsService
        self.zoneSetting = settingsService.selectedHeartZoneSetting
        self.zones = zoneSetting.zones.map({ HeartZoneViewModel(zone: $0) })
    
        initBindings()
    }
    
    private func initBindings() {
        var listOfInterestingPublishers: [Published<Int>.Publisher] = []
        
        // TODO: Rewrite to be more safe
        for i in 0..<zones.count {
            let currZone = zones[i]
            listOfInterestingPublishers.append(currZone.$upperBound)
            listOfInterestingPublishers.append(currZone.$lowerBound)

            let prevZone: HeartZoneViewModel? = i - 1 >= 0 ? zones[i - 1] : nil
            let nextZone: HeartZoneViewModel? = i + 1 < zones.count ? zones[i + 1] : nil

            zones[i].setBounds(prevZone: prevZone, nextZone: nextZone)
        }
        
        Publishers
            .MergeMany(listOfInterestingPublishers)
            .debounce(for: .seconds(0.6), scheduler: RunLoop.main, options: nil)
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveZone()
            }
            .store(in: &cancellables)
    }
    
    private func saveZone() {
        settingsService.selectedHeartZoneSetting = HeartZonesSetting(zones: zones.map{ $0.getHeartZone() })
        print("saving")
    }
}

