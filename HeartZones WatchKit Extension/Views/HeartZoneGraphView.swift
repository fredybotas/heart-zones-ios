//
//  HeartZoneGraphView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/11/2021.
//

import SwiftUI

struct HeartZoneGraphView: View {
    @ObservedObject var heartZoneGraphViewModel: HeartZoneGraphViewModel

    func interpolateBpm(height: Int, bpm: Int, minBpm: Int, maxBpm: Int) -> CGFloat {
        return (CGFloat(height) / 2)
            - ((CGFloat(bpm) - CGFloat(minBpm)) * (CGFloat(height) / 2) / CGFloat(maxBpm - minBpm))
    }

    func bpmsToPath(
        height: Int, width _: Int, bpms: [BpmEntry], path: inout Path, offset: inout CGFloat
    ) {
        if bpms.isEmpty {
            return
        }
        let bpmMin = 60
        let bpmMax = 220
        path.move(
            to: CGPoint(
                x: offset,
                y: interpolateBpm(height: height, bpm: bpms[0].value, minBpm: bpmMin, maxBpm: bpmMax)
            ))
        for point in bpms.dropFirst() {
            // offset += x_offset
            path.addLine(
                to: CGPoint(
                    x: offset,
                    y: interpolateBpm(height: height, bpm: point.value, minBpm: bpmMin, maxBpm: bpmMax)
                )) // , control: CGPoint(x: x_offset - 10, y: CGFloat(height - bpms[bpm_index])))
        }
    }

    var body: some View {
        GeometryReader { geo in
            Text(self.heartZoneGraphViewModel.bpmTimeDuration)
                .font(.footnote)
                .foregroundColor(.gray)
            var offset: CGFloat = 0
            ForEach(heartZoneGraphViewModel.bpms, id: \.self) { bpm in
                Path { path in
                    self.bpmsToPath(
                        height: Int(geo.size.height), width: Int(geo.size.width), bpms: bpm.bpms, path: &path,
                        offset: &offset
                    )
                }
                .stroke(
                    bpm.color.toColor(), style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round)
                )
            }
            .id(UUID())
            Rectangle()
                .frame(width: geo.size.width, height: 1, alignment: .center)
                .background(Color.gray)
                .offset(x: 0, y: geo.size.height / 2 + 10)
        }
    }
}

struct HeartZoneGraphView_Previews: PreviewProvider {
    static var previews: some View {
        HeartZoneGraphView(
            heartZoneGraphViewModel: HeartZoneGraphViewModel(healthKitService: HealthKitService()))
    }
}
