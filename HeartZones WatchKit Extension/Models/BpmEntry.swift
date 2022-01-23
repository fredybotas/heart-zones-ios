//
//  BpmEntry.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//

import Foundation

struct BpmEntry: Equatable, Hashable {
    let value: Int
    let timestamp: TimeInterval
}

class BpmEntrySegment {
    let startDate: Date
    let endDate: Date
    let entries: [BpmEntry]

    init(startDate: Date, endDate: Date, entries: [BpmEntry]) {
        self.startDate = startDate
        self.endDate = endDate
        self.entries = entries
    }
}
