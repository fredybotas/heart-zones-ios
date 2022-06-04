//
//  PurchasesService.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 03/06/2022.
//

import Foundation

protocol IPurchasesService {
    var isInAppPurchaseEnabled: Bool { get }
}

class PurchasesService: IPurchasesService {    
    var isInAppPurchaseEnabled: Bool {
        return true
    }
}

