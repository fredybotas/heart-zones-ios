//
//  HostingController.swift
//  HeartZonesWatchKit WatchKit Extension
//
//  Created by Michal Manak on 28/06/2021.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<WorkoutSelectionView> {
    override var body: WorkoutSelectionView {
        return WorkoutSelectionView(workoutSelectionViewModel: WorkoutSelectionViewModel())
    }
}
