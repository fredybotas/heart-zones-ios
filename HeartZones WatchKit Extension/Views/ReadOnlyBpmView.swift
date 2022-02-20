//
//  ReadOnlyBpmView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 18/02/2022.
//

import SwiftUI

struct ReadOnlyBpmView: View {
    struct IndicatorView: View {
        let zones: [ReadOnlyBpmViewModel.Zone]
        let percentage: CGFloat
        
        private let kHeight: CGFloat = 20
        private let kRadius: CGFloat = 8
        private let kSpacing: CGFloat = 1

        func getRectangleBaseWidth(_ geo: GeometryProxy, zonesCount: Int) -> CGFloat {
            return geo.size.width - CGFloat(zonesCount - 1) * kSpacing
        }

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .trailing) {
                    HStack(spacing: kSpacing) {
                        ForEach(zones, id: \.self) { zone in
                            RoundedRectangle(cornerRadius: kRadius)
                                .frame(width: getRectangleBaseWidth(geo, zonesCount: zones.count) * (zone.upperPercentage - zone.lowerPercentage), height: kHeight)
                                .foregroundColor(zone.color)
                        }
                    }
                    Rectangle()
                        .frame(width: geo.size.width * (1.0 - percentage), height: kHeight)
                        .foregroundColor(Color.black)
                        .opacity(0.75)
                }
            }
            .frame(height: kHeight)
        }
    }

    struct BpmView: View {
        let bpm: String
        let color: Color
        
        var body: some View {
                Text(bpm)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .font(
                        Font.system(size: 62, weight: .light, design: .default)
                    )
                    .frame(width: 100, alignment: .center)
            
        }
    }
    
    @ObservedObject var readOnlyBpmViewModel: ReadOnlyBpmViewModel

    var body: some View {
        VStack {
            IndicatorView(zones: readOnlyBpmViewModel.zones, percentage: readOnlyBpmViewModel.zonesPercentage)
            BpmView(bpm: readOnlyBpmViewModel.bpmText, color: readOnlyBpmViewModel.bpmTextColor)
        }
    }
}

struct ReadOnlyBpmView_Previews: PreviewProvider {
    static var previews: some View {
        ReadOnlyBpmView(readOnlyBpmViewModel: ReadOnlyBpmViewModel(healthKitService: HealthKitService(), settingsService: SettingsService(settingsRepository: SettingsRepository(), healthKitService: HealthKitService())))
    }
}
