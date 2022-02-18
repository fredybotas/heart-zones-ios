//
//  HeartZoneSettingsViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/09/2021.
//

import Combine
import Foundation
import SwiftUI

class HeartZoneViewModel: ObservableObject, Identifiable {
    let zone: HeartZone
    let isLast: Bool

    @Published var lowerBound: Int
    @Published var upperBound: Int

    @Published var minBound: Int
    @Published var maxBound: Int

    @Published var crown: Double

    var color: Color
    var name: String

    var cancellables = Set<AnyCancellable>()

    init(zone: HeartZone, isLast: Bool) {
        self.zone = zone
        self.isLast = isLast
        lowerBound = zone.bpmRangePercentage.lowerBound
        upperBound = zone.bpmRangePercentage.upperBound

        minBound = 0
        maxBound = 100

        color = zone.color.toColor()
        name = zone.name

        crown = Double(zone.bpmRangePercentage.upperBound)
        if !isLast {
            $crown
                .removeDuplicates()
                .sink(receiveValue: { val in
                    self.upperBound = Int(val)
                })
                .store(in: &cancellables)
        }
        $upperBound
            .removeDuplicates()
            .map { Double($0) }
            .sink { [weak self] val in
                self?.crown = val
            }
            .store(in: &cancellables)
    }

    func getHeartZone() -> HeartZone {
        return HeartZone(
            id: zone.id, name: zone.name, bpmRangePercentage: lowerBound ... upperBound, color: zone.color,
            target: zone.target
        )
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
        zoneSetting = settingsService.selectedHeartZoneSetting
        zones = zoneSetting.zones
            .enumerated()
            .map { [zoneCount = zoneSetting.zones.count] index, zone in
                HeartZoneViewModel(zone: zone, isLast: index == zoneCount - 1)
            }

        initBindings()
    }

    private func initBindings() {
        var listOfInterestingPublishers: [Published<Int>.Publisher] = []

        // TODO: Rewrite to be more safe
        for index in 0 ..< zones.count {
            let currZone = zones[index]
            listOfInterestingPublishers.append(currZone.$upperBound)
            listOfInterestingPublishers.append(currZone.$lowerBound)

            let prevZone: HeartZoneViewModel? = index - 1 >= 0 ? zones[index - 1] : nil
            let nextZone: HeartZoneViewModel? = index + 1 < zones.count ? zones[index + 1] : nil

            zones[index].setBounds(prevZone: prevZone, nextZone: nextZone)
        }

        Publishers
            .MergeMany(listOfInterestingPublishers)
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main, options: nil)
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveZone()
            }
            .store(in: &cancellables)
    }

    private func saveZone() {
        settingsService.selectedHeartZoneSetting = HeartZonesSetting(
            zones: zones.map { $0.getHeartZone() })
    }
}
