//
//  HeartZoneGraphViewModel.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/11/2021.
//

import Foundation
import Combine
import SwiftUI

struct BpmSegment: Hashable {
    let color: HeartZone.Color
    let bpms: [BpmEntry]
}

class HeartZoneGraphViewModel: ObservableObject {
    var bpmTimeInterval: TimeInterval = 0
    @Published var bpms: [BpmSegment] = []
    @Published var bpmTimeDuration: String = "--"
    @Published var end: CGFloat = CGFloat.zero
    
    private var refreshTimer: AnyCancellable?
    private let healthKit: IHealthKitService
    private var bpmCancellable: AnyCancellable?
    
    init(healthKitService: IHealthKitService) {
        self.healthKit = healthKitService
        self.refreshTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink() { [weak self] _ in
                self?.bpmCancellable = self?
                    .healthKit
                    .getBpmData(startDate: Date(timeIntervalSinceNow: -5 * 60) as NSDate)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { val in
                        self?.processBpmValues(bpmEntries: val)
                    })
            }
    }
    
    private func processBpmValues(bpmEntries: [BpmEntry]) {
        self.bpmTimeInterval = (bpmEntries.last?.timestamp ?? 0) - (bpmEntries.first?.timestamp ?? 0)
        self.bpms = [BpmSegment(color: HeartZone.Color(red: 120, green: 0, blue: 0), bpms: bpmEntries)]
        
        var min: TimeInterval = Double.infinity
        var max: TimeInterval = -Double.infinity
        if bpmEntries.isEmpty {
            self.bpmTimeDuration = "--"
            return
        }
        for entry in bpmEntries {
            if entry.timestamp < min {
                min = entry.timestamp
            }
            if entry.timestamp > max {
                max = entry.timestamp
            }
        }
        let interval = max - min
        if interval >= 60 {
            self.bpmTimeDuration = String(Int((interval / 60).rounded())) + "m"
        } else {
            self.bpmTimeDuration = String(Int(interval)) + "s"
        }
    }
}
