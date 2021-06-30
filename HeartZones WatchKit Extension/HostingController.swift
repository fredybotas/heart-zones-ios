//
//  HostingController.swift
//  HeartZonesWatchKit WatchKit Extension
//
//  Created by Michal Manak on 28/06/2021.
//

import WatchKit
import Foundation
import SwiftUI
import Swinject

class DIHostingController<Type>: WKHostingController<Type> where Type: View {
    let container: Container = {
        let delegate = WKExtension.shared().delegate as! ExtensionDelegate
        return delegate.container
    }()
}

class HostingControllerWorkoutSelection: DIHostingController<WorkoutSelectionView> {
    static let identifier = "HostingControllerWorkoutSelection"

    func presentRunningWorkoutController(workoutType: WorkoutType) {
        let contexts: [Any?] = [nil, workoutType, nil]
        
        WKInterfaceController.reloadRootPageControllers(withNames: [HostingControllerWorkoutControls.identifier, HostingControllerRunningWorkout.identifier, PlayingNowController.identifier], contexts: contexts as [Any], orientation: WKPageOrientation.horizontal, pageIndex: 1)
    }
    
    override var body: WorkoutSelectionView {
        return WorkoutSelectionView(workoutSelectionViewModel: container.resolve(WorkoutSelectionViewModel.self)!, controller: self)
    }
}

class HostingControllerRunningWorkout: DIHostingController<WorkoutRunningView> {
    static let identifier = "HostingControllerRunningWorkout"
    var workoutType: WorkoutType?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        workoutType = context as? WorkoutType
    }
        
    override var body: WorkoutRunningView {
        return WorkoutRunningView(workoutViewModel: container.resolve(WorkoutViewModel.self, argument: workoutType!)!)
    }
}

class HostingControllerWorkoutControls: DIHostingController<WorkoutControlsView> {
    static let identifier = "HostingControllerWorkoutControls"
    
    func popControllers() {
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(HostingControllerWorkoutSelection.identifier, self)])
    }
    
    override var body: WorkoutControlsView {
        return WorkoutControlsView(workoutControlsViewModel: container.resolve(WorkoutControlsViewModel.self)!, controller: self)
    }
}

class PlayingNowController: WKInterfaceController {
    static let identifier = "PlayingNowController"
    
}


