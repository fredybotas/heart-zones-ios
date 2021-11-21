//
//  SunViewWithMinutes.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 17/07/2021.
//

import SwiftUI

struct SunViewWithMinutes: View {
    let minutesLeft: Int
    let sunVisibility: Double
    let fontSize: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SunView(sunVisibility: sunVisibility)
                .contentShape(Rectangle())
                .clipShape(Rectangle())
                .clipped()
            if minutesLeft > 0 {
                Text(String(minutesLeft))
                    .font(Font.system(size: fontSize, weight: .medium, design: .default))
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct SunViewWithMinutes_Previews: PreviewProvider {
    static var previews: some View {
        SunViewWithMinutes(minutesLeft: 45, sunVisibility: 0.75, fontSize: 16)
    }
}
