//
//  UserDefaultsManager.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 03/10/2021.
//

import Foundation

class UserDefaultsManager {
    let defaults = UserDefaults.standard
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }

    func save(_ element: Int?, key: String) {
        defaults.set(element, forKey: key)
    }

    func save(_ element: Bool?, key: String) {
        defaults.set(element, forKey: key)
    }

    func save<T: Codable>(_ element: T?, key: String) {
        if let element = element {
            guard let encodedElement = try? encoder.encode(element) else { return }
            defaults.set(encodedElement, forKey: key)
        } else {
            defaults.set(nil, forKey: key)
        }
    }

    func get<T: Codable>(key: String) -> T? {
        if isKeyPresentInUserDefaults(key: key) {
            guard let decodedJson = defaults.object(forKey: key) as? Data else { return nil }
            guard let distanceMetric = try? decoder.decode(T.self, from: decodedJson) else {
                return nil
            }
            return distanceMetric
        }
        return nil
    }

    func get(key: String) -> Int? {
        if isKeyPresentInUserDefaults(key: key) {
            return defaults.integer(forKey: key)
        }
        return nil
    }

    func get(key: String) -> Bool? {
        if isKeyPresentInUserDefaults(key: key) {
            return defaults.bool(forKey: key)
        }
        return nil
    }
}
