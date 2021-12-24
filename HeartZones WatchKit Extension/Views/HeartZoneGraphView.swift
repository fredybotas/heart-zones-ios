//
//  HeartZoneGraphView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/11/2021.
//

import SwiftUI

private let xOffset: Double = 20
private let bpmOffset = 40
struct HeartZoneGraphView: View {
    @ObservedObject var heartZoneGraphViewModel: HeartZoneGraphViewModel

    func interpolateBpm(height: Int, bpm: Int, minBpm: Int, maxBpm: Int) -> CGFloat {
        if minBpm == maxBpm {
            return 0
        }
        return CGFloat(bpmOffset) +
            CGFloat(height - bpmOffset) -
            ((CGFloat(bpm) - CGFloat(minBpm)) * CGFloat(height - bpmOffset) / CGFloat(maxBpm - minBpm))
    }

    func bpmsToPath(
        height: Int, width: Int, bpms: [BpmEntry], path: inout Path
    ) {
        if bpms.isEmpty {
            return
        }
        let offsetCoef = Double(width) /
            Double(heartZoneGraphViewModel.bpmMaxTimestamp - heartZoneGraphViewModel.bpmMinTimestamp)
        path.move(
            to: CGPoint(
                x: xOffset + (bpms.first!.timestamp - heartZoneGraphViewModel.bpmMinTimestamp) * offsetCoef,
                y: interpolateBpm(
                    height: height,
                    bpm: bpms[0].value,
                    minBpm: heartZoneGraphViewModel.bpmMin,
                    maxBpm: heartZoneGraphViewModel.bpmMax
                )
            ))
        for point in bpms.dropFirst() {
            let moveTo = (point.timestamp - heartZoneGraphViewModel.bpmMinTimestamp) * offsetCoef
            path.addLine(
                to: CGPoint(
                    x: xOffset + moveTo,
                    y: interpolateBpm(
                        height: height,
                        bpm: point.value,
                        minBpm: heartZoneGraphViewModel.bpmMin,
                        maxBpm: heartZoneGraphViewModel.bpmMax
                    )
                )
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            Text(self.heartZoneGraphViewModel.bpmTimeDuration)
                .font(.footnote)
                .foregroundColor(.gray)
            ForEach(heartZoneGraphViewModel.zoneMargins, id: \.self) { margin in
                let yOffset = interpolateBpm(
                    height: Int(geo.size.height),
                    bpm: margin.bpm,
                    minBpm: heartZoneGraphViewModel.bpmMin,
                    maxBpm: heartZoneGraphViewModel.bpmMax
                )
                Rectangle()
                    .frame(width: geo.size.width, height: 0.6, alignment: .center)
                    .foregroundColor(.gray)
                    .opacity(0.5)
                    .offset(
                        x: 0,
                        y: yOffset - 0.5
                    )
                Text(margin.name)
                    .font(Font.system(size: 9, weight: .medium, design: .default))
                    .foregroundColor(.gray)
                    .opacity(0.6)
                    .offset(x: 0, y: yOffset + 1)
                Text(String(margin.bpm))
                    .font(Font.system(size: 9, weight: .medium, design: .default))
                    .foregroundColor(.gray)
                    .opacity(0.6)
                    .offset(x: 0, y: yOffset - 12)
            }
            ForEach(heartZoneGraphViewModel.bpms, id: \.self) { bpm in
                Path { path in
                    self.bpmsToPath(
                        height: Int(geo.size.height), width: Int(geo.size.width), bpms: bpm.bpms, path: &path
                    )
                }
                .stroke(
                    bpm.color.toColor(), style: StrokeStyle(lineWidth: 1.2, lineCap: .butt, lineJoin: .round)
                )
            }
            .id(UUID())
        }
    }
}

struct HeartZoneGraphView_Previews: PreviewProvider {
    static var previews: some View {
        HeartZoneGraphView(
            heartZoneGraphViewModel: HeartZoneGraphViewModel(
                healthKitService: HealthKitService(),
                settingsService: SettingsService(
                    settingsRepository: SettingsRepository(),
                    healthKitService: HealthKitService()
                )
            ))
    }
}
