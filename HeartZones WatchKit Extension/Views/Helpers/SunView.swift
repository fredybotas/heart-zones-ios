//
//  SunView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 04/07/2021.
//

import SwiftUI

struct SunView: View {
    
    var sunVisibility: Double
    
    var body: some View {
        GeometryReader() { geometry in
            Circle()
                .fill(Color.yellow)
                .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + geometry.size.height * (1 - CGFloat(sunVisibility)))
        }
    }
}

struct SunView_Previews: PreviewProvider {
    static var previews: some View {
        SunView(sunVisibility: 0.5)
    }
}
