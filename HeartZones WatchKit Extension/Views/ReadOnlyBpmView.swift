//
//  ReadOnlyBpmView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 18/02/2022.
//

import SwiftUI

struct ReadOnlyBpmView: View {
    struct IndicatorView: View {
        let percentage: UInt
        private let kHeight: CGFloat = 20
        private let kRadius: CGFloat = 8
        private let kSpacing: CGFloat = 1

        func getRectangleBaseWidth(_ geo: GeometryProxy) -> CGFloat {
            // TODO: Change 4 to actual rectangle count
            let rectangleCount = 4
            return geo.size.width - CGFloat(rectangleCount - 1) * kSpacing
        }

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    HStack(spacing: kSpacing) {
                        RoundedRectangle(cornerRadius: kRadius)
                            .frame(width: getRectangleBaseWidth(geo) * 0.3, height: kHeight)
                            .foregroundColor(Color.blue)
                        RoundedRectangle(cornerRadius: kRadius)
                            .frame(width: getRectangleBaseWidth(geo) * 0.2, height: kHeight)
                            .foregroundColor(Color.green)
                        RoundedRectangle(cornerRadius: kRadius)
                            .frame(width: getRectangleBaseWidth(geo) * 0.2, height: kHeight)
                            .foregroundColor(Color.orange)
                        RoundedRectangle(cornerRadius: kRadius)
                            .frame(width: getRectangleBaseWidth(geo) * 0.3, height: kHeight)
                            .foregroundColor(Color.red)
                    }
                    Rectangle()
                        .frame(width: geo.size.width * (1.0 - (CGFloat(percentage) / 100.0)), height: kHeight)
                        .foregroundColor(Color.black)
                        .opacity(0.75)
                }
            }
            .frame(height: kHeight)
        }
    }

    struct BpmView: View {
        let bpm: UInt

        var body: some View {
            HStack(alignment: .bottom, spacing: 2) {
                Text("144")
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundColor(Color.orange)
                    .font(
                        Font.system(size: 62, weight: .light, design: .default)
                    )
                    .frame(width: 100, alignment: .leading)
            }
        }
    }

    var body: some View {
        VStack {
            IndicatorView(percentage: 60)
            BpmView(bpm: 142)
        }
    }
}

struct ReadOnlyBpmView_Previews: PreviewProvider {
    static var previews: some View {
        ReadOnlyBpmView()
    }
}
