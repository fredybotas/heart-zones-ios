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
