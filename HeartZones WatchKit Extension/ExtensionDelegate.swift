//
//  ExtensionDelegate.swift
//  HeartZonesWatchKit WatchKit Extension
//
//  Created by Michal Manak on 28/06/2021.
//

import WatchKit
import HealthKit
import Swinject

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    let container: Container = {
        let container = Container()
        container.register(WorkoutService.self, factory: { resolver in
            return WorkoutService()
        }).inObjectScope(.container)
        container.register(HeartZoneService.self, factory: { resolver in
            return HeartZoneService()
        }).inObjectScope(.container)
        
        container.register(WorkoutSelectionViewModel.self, factory: { resolver in
            return WorkoutSelectionViewModel()
        })
        container.register(WorkoutViewModel.self, factory: { (resolver, workoutType: WorkoutType) in
            let workoutService = resolver.resolve(WorkoutService.self)!
            let heartZoneService = resolver.resolve(HeartZoneService.self)!

            return WorkoutViewModel(workoutType: workoutType, workoutService: workoutService, heartZoneService: heartZoneService)
        })
        container.register(WorkoutControlsViewModel.self, factory: { resolver in
            let workoutService = resolver.resolve(WorkoutService.self)!
            return WorkoutControlsViewModel(workoutService: workoutService)
        })
        
        return container
    }()
    
    func authorizeHealthKitAccess(toRead readable: Set<HKObjectType>?, toWrite writable: Set<HKSampleType>?, completion: @escaping (Bool, HKError.Code?) -> Void)
    {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, .errorHealthDataUnavailable)
            return
        }
        HKHealthStore().requestAuthorization(toShare: writable, read: readable) { (authorized, error) in
            guard authorized else {
                guard error != nil else {
                    completion(false, .noError)
                    return
                }
                print("HealthKit Error:\n\(error!)") // Comment this out for release
                completion(false, .errorAuthorizationDenied)
                return
            }
            completion(true, nil)
        }
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        authorizeHealthKitAccess(toRead: [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ], toWrite: [
            HKQuantityType.workoutType()
        ], completion: { (result, code) in
            print(result)
        })
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
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