//
//  HostingController.swift
//  HeartZonesWatchKit WatchKit Extension
//
//  Created by Michal Manak on 28/06/2021.
//

import Foundation
import SwiftUI
import Swinject
import WatchKit

class DIContainer {
    static let shared: Container = {
        // swiftlint:disable:next force_cast
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        return delegate.container
    }()
}

// class DIHostingController<Type>: WKHostingController<Type> where Type: View {
//    let container: Container = {
//        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
//        return delegate.container
//    }()
// }

class HostingControllerWorkoutSelection: WKHostingController<WorkoutSelectionView> {
    static let identifier = "HostingControllerWorkoutSelection"

    static func presentRunningWorkoutController(workoutType: WorkoutType) {
        let contexts: [Any?] = [nil, workoutType, nil]

        WKInterfaceController.reloadRootPageControllers(
            withNames: [
                HostingControllerWorkoutControls.identifier,
                HostingControllerRunningWorkout.identifier,
                HostingControllerWorkoutGraph.identifier,
                HostingControllerWorkoutBars.identifier
            ], contexts: contexts as [Any], orientation: WKPageOrientation.horizontal, pageIndex: 1
        )
    }

    override var body: WorkoutSelectionView {
        return WorkoutSelectionView(
            workoutSelectionViewModel: DIContainer.shared.resolve(WorkoutSelectionViewModel.self)!
        )
    }
}

class HostingControllerRunningWorkout: WKHostingController<WorkoutRunningView> {
    static let identifier = "HostingControllerRunningWorkout"
    var workoutType: WorkoutType!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        workoutType = context as? WorkoutType
    }

    override var body: WorkoutRunningView {
        return WorkoutRunningView(
            workoutViewModel: DIContainer.shared.resolve(WorkoutViewModel.self, argument: workoutType)!)
    }
}

class HostingControllerWorkoutControls: WKHostingController<WorkoutControlsView> {
    static let identifier = "HostingControllerWorkoutControls"

    func presentWorkoutSummaryView() {
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [
            (HostingControllerWorkoutSummary.identifier, self)
        ])
    }

    override var body: WorkoutControlsView {
        return WorkoutControlsView(
            workoutControlsViewModel: DIContainer.shared.resolve(WorkoutControlsViewModel.self)!,
            controller: self
        )
    }
}

class PlayingNowController: WKInterfaceController {
    static let identifier = "PlayingNowController"
}

class HostingControllerWorkoutSummary: WKHostingController<WorkoutSummaryView> {
    static let identifier = "HostingControllerWorkoutSummary"

    func popControllers() {
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [
            (HostingControllerWorkoutSelection.identifier, self)
        ])
    }

    override var body: WorkoutSummaryView {
        return WorkoutSummaryView(
            controller: self,
            workoutSummaryViewModel: DIContainer.shared.resolve(WorkoutSummaryViewModel.self)!
        )
    }
}

class HostingControllerWorkoutGraph: WKHostingController<HeartZoneGraphView> {
    static let identifier = "HostingControllerWorkoutGraph"

    override var body: HeartZoneGraphView {
        return HeartZoneGraphView(
            heartZoneGraphViewModel: DIContainer.shared.resolve(HeartZoneGraphViewModel.self)!)
    }
}

class HostingControllerWorkoutBars: WKHostingController<HeartZoneBarsView> {
    static let identifier = "HostingControllerWorkoutBars"

    override var body: HeartZoneBarsView {
        return HeartZoneBarsView(
            heartZoneBarsViewModel: DIContainer.shared.resolve(HeartZoneBarsViewModel.self)!)
    }
}
