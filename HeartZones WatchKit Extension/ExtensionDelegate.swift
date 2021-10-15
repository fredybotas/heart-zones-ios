//
//  ExtensionDelegate.swift
//  HeartZonesWatchKit WatchKit Extension
//
//  Created by Michal Manak on 28/06/2021.
//

import WatchKit
import HealthKit
import Swinject
import Combine

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    let container: Container = {
        let container = Container()
        // Services should persist thtourhg whole app
        container.register(DeviceBeepingManager.self, factory: { resolver in
            return DeviceBeepingManager(beeper: DeviceBeeperDelayProxy())
        }).inObjectScope(.container)
        container.register(BeepingService.self, factory: { resolver in
            let beeper = resolver.resolve(DeviceBeepingManager.self)!
            let settingsService = resolver.resolve(SettingsService.self)!
            return BeepingService(beeper: beeper, settingsService: settingsService)
        }).inObjectScope(.container)
        container.register(HealthKitService.self, factory: { resolver in
            return HealthKitService()
        }).inObjectScope(.container)
        container.register(LocationManager.self, factory: { resolver in
            return LocationManager()
        }).inObjectScope(.container)
        container.register(SunService.self, factory: { resolver in
            let locationManager = resolver.resolve(LocationManager.self)!
            return SunService(locationManager: locationManager)
        }).inObjectScope(.container)
        
        container.register(WorkoutService.self, factory: { resolver in
            let locationManager = resolver.resolve(LocationManager.self)!
            let healthKitService = resolver.resolve(HealthKitService.self)!
            return WorkoutService(locationManager: locationManager, healthKitService: healthKitService)
        }).inObjectScope(.container)
        
        container.register(HeartZoneService.self, factory: { resolver in
            let workoutService = resolver.resolve(WorkoutService.self)!
            let beepingService = resolver.resolve(BeepingService.self)!
            let healthKitService = resolver.resolve(HealthKitService.self)!
            let settingsService = resolver.resolve(SettingsService.self)!

            return HeartZoneService(workoutService: workoutService, beepingService: beepingService, healthKitService: healthKitService, settingsService: settingsService)
        }).inObjectScope(.container)
        container.register(AuthorizationManager.self, factory: { resolver in
            let healthKit = container.resolve(HealthKitService.self)!
            // LocationManager needs to be last with current implementation
            let locationManager = container.resolve(LocationManager.self)!
            return AuthorizationManager(authorizables: [healthKit, locationManager])
        }).inObjectScope(.container)
        

        container.register(SettingsRepositoryCached.self, factory: { resolver in
            return SettingsRepositoryCached()
        }).inObjectScope(.container)
        container.register(SettingsService.self, factory: { resolver in
            let healthKitService = container.resolve(HealthKitService.self)!
            let settingsRepository = container.resolve(SettingsRepositoryCached.self)!
            
            return SettingsService(settingsRepository: settingsRepository, healthKitService: healthKitService)
        }).inObjectScope(.container)
        
        // Get new viewModel every time when requested
        container.register(WorkoutSelectionViewModel.self, factory: { resolver in
            return WorkoutSelectionViewModel()
        })
        container.register(SettingsViewModel.self, factory: { resolver in
            let settingsService = resolver.resolve(SettingsService.self)!
            return SettingsViewModel(settingsService: settingsService)
        })
        container.register(WorkoutViewModel.self, factory: { (resolver, workoutType: WorkoutType!) in
            let workoutService = resolver.resolve(WorkoutService.self)!
            let heartZoneService = resolver.resolve(HeartZoneService.self)!
            let sunService = resolver.resolve(SunService.self)!
            let settingsService = resolver.resolve(SettingsService.self)!
            return WorkoutViewModel(workoutType: workoutType, workoutService: workoutService, heartZoneService: heartZoneService, sunService: sunService, settingsService: settingsService)
        })
        container.register(WorkoutControlsViewModel.self, factory: { resolver in
            let workoutService = resolver.resolve(WorkoutService.self)!
            return WorkoutControlsViewModel(workoutService: workoutService)
        })
        container.register(HeartZoneSettingsViewModel.self, factory: { resolver in
            let settingsService = resolver.resolve(SettingsService.self)!
            return HeartZoneSettingsViewModel(settingsService: settingsService)
        })
        
        return container
    }()
    
    enum AppState {
        case background, foreground
    }
    
    let appStateChangePublisher = CurrentValueSubject<AppState, Never>(.foreground)

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        let authorizationManager = container.resolve(AuthorizationManager.self)!
        authorizationManager.startAuthorizationChain()
    }

    func applicationDidBecomeActive() {
        appStateChangePublisher.send(.foreground)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        appStateChangePublisher.send(.background)
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
