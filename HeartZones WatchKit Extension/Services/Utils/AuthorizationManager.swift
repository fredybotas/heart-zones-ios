//
//  AuthorizationManager.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 24/07/2021.
//

import Foundation
import Combine

public protocol Authorizable {
    func requestAuthorization() -> Future<Bool, Never>
}

fileprivate let kAuthorizationTriesCount = 2

class AuthorizationManager {
    
    private let authorizables: [(Authorizable, Int)]
    private var iterator: IndexingIterator<[(Authorizable, Int)]>?
    private var cancellable: AnyCancellable?
    
    init(authorizables: [Authorizable]) {
        self.authorizables = authorizables.map { ($0, kAuthorizationTriesCount) }
    }
    
    func startAuthorizationChain() {
        if iterator == nil {
            iterator = authorizables.makeIterator()
            handleNextRequest()
        }
    }
    
    private func handleNextRequest() {
        guard let element = iterator?.next() else {
            // chain finished
            self.iterator = nil;
            return
        }

        authorize(authorizable: element.0, triesLeft: element.1)
    }
    
    private func authorize(authorizable: Authorizable, triesLeft: Int) {
        cancellable = authorizable
            .requestAuthorization()
            .sink { [weak self] success in
                if !success && triesLeft > 0 {
                    self?.authorize(authorizable: authorizable, triesLeft: triesLeft - 1)
                } else {
                    self?.handleNextRequest()
                }
            }
    }
}
