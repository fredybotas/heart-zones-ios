//
//  BpmEntry.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//

import Combine
import Foundation

struct BpmEntry: Equatable, Hashable {
    let value: Int
    let timestamp: TimeInterval
}

class BpmEntrySegment {
    let startDate: Date
    let endDate: Date
    var entries: [BpmEntry]?
    var entriesPromise: AnyCancellable?

    convenience init(startDate: Date, endDate: Date, entries: [BpmEntry]) {
        self.init(startDate: startDate, endDate: endDate)
        self.entries = entries
    }

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }

    func fillEntries(healthKitService: IHealthKitService) {
        let group = DispatchGroup()
        group.enter()
        entriesPromise = healthKitService.getBpmData(
            startDate: startDate as NSDate,
            endDate: endDate as NSDate
        )
        .sink(
            receiveValue: { [weak self, group] val in
                self?.entries = val
                group.leave()
            })
        group.wait()
    }
}
