//
//  SunViewWithMinutes.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 17/07/2021.
//

import SwiftUI

struct SunViewWithMinutes: View {
    var minutesLeft: Int
    var sunVisibility: Double
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SunView(sunVisibility: sunVisibility)
                .contentShape(Rectangle())
                .clipShape(Rectangle())
                .clipped()
            if minutesLeft > 0 {
                Text(String(minutesLeft))
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct SunViewWithMinutes_Previews: PreviewProvider {
    static var previews: some View {
        SunViewWithMinutes(minutesLeft: 45, sunVisibility: 0.75)
    }
}
