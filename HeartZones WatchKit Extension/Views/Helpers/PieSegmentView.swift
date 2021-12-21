//
//  PieSegmentView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 26/06/2021.
//

import SwiftUI

struct PieSegment: Shape {
    var ratio: Double

    private func getAngle() -> Angle {
        var calculatedRatio: Double = ratio
        if ratio < 0.05 {
            calculatedRatio = 0.05
        }
        return -Angle(degrees: calculatedRatio * 360.0)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(
            center: center, radius: rect.midX, startAngle: -.degrees(90),
            endAngle: getAngle() - .degrees(90), clockwise: true
        )
        return path
    }
}

struct PieSegmentView_Previews: PreviewProvider {
    static var previews: some View {
        PieSegment(ratio: 0.1)
    }
}
