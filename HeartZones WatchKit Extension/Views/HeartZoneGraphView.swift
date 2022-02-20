//
//  HeartZoneGraphView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak on 27/11/2021.
//

import SwiftUI

private let xOffset: CGFloat = 20
private let bpmOffset = 30
private let kCurveMarginPart: CGFloat = 0.8

struct HeartZoneGraphView: View {
    @ObservedObject var heartZoneGraphViewModel: HeartZoneGraphViewModel

    func interpolateBpm(height: Int, bpm: Int, minBpm: Int, maxBpm: Int) -> CGFloat {
        if minBpm == maxBpm {
            return 0
        }
        let bpmAdjusted: Int!
        if bpm > maxBpm {
            bpmAdjusted = maxBpm
        } else if bpm < minBpm {
            bpmAdjusted = minBpm
        } else {
            bpmAdjusted = bpm
        }
        return CGFloat(bpmOffset) +
            CGFloat(height - bpmOffset) -
            ((CGFloat(bpmAdjusted) - CGFloat(minBpm)) * CGFloat(height - bpmOffset) / CGFloat(maxBpm - minBpm))
    }

    // swiftlint:disable:next function_body_length
    func bpmsToPath(
        height: Int, width: Int, bpms: [BpmEntry], path: inout Path
    ) {
        if bpms.isEmpty {
            return
        }
        let offsetCoef = Double(width - Int(xOffset)) /
            Double(heartZoneGraphViewModel.bpmMaxTimestamp - heartZoneGraphViewModel.bpmMinTimestamp)
        let startPoint = CGPoint(
            x: xOffset + (bpms.first!.timestamp - heartZoneGraphViewModel.bpmMinTimestamp) * offsetCoef,
            y: interpolateBpm(
                height: height,
                bpm: bpms[0].value,
                minBpm: heartZoneGraphViewModel.bpmMin,
                maxBpm: heartZoneGraphViewModel.bpmMax
            )
        )
        path.move(to: startPoint)
        var curveControlPoint: (CGFloat, CGFloat)?
        var prevPoint = startPoint
        for i in 1 ..< bpms.count {
            let originMoveToX = CGFloat(
                xOffset +
                    ((bpms[i].timestamp - heartZoneGraphViewModel.bpmMinTimestamp) * offsetCoef)
            )
            let originMoveToY = interpolateBpm(
                height: height,
                bpm: bpms[i].value,
                minBpm: heartZoneGraphViewModel.bpmMin,
                maxBpm: heartZoneGraphViewModel.bpmMax
            )
            let startX = prevPoint.x + ((originMoveToX - prevPoint.x) * (1.0 - kCurveMarginPart))
            let startY = prevPoint.y + ((originMoveToY - prevPoint.y) * (1.0 - kCurveMarginPart))
            let moveToX = prevPoint.x + ((originMoveToX - prevPoint.x) * kCurveMarginPart)
            let moveToY = prevPoint.y + ((originMoveToY - prevPoint.y) * kCurveMarginPart)
            if let curveControlPoint = curveControlPoint {
                path.addQuadCurve(to: CGPoint(x: startX, y: startY),
                                  control: CGPoint(x: curveControlPoint.0, y: curveControlPoint.1))
            }
            if i == bpms.count - 1 {
                path.addLine(
                    to: CGPoint(
                        x: originMoveToX,
                        y: originMoveToY
                    )
                )
            } else {
                path.addLine(
                    to: CGPoint(
                        x: moveToX,
                        y: moveToY
                    )
                )
            }
            prevPoint = CGPoint(x: originMoveToX, y: originMoveToY)
            curveControlPoint = (originMoveToX, originMoveToY)
        }
    }

    var body: some View {
        if heartZoneGraphViewModel.showLoadingScreen {
            Text("Waiting for more data")
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .onAppear(perform: { self.heartZoneGraphViewModel.isScreenVisible = true })
                .onDisappear(perform: { self.heartZoneGraphViewModel.isScreenVisible = false })
        } else {
            GeometryReader { geo in
                Text(self.heartZoneGraphViewModel.bpmTimeDuration)
                    .frame(width: geo.size.width, alignment: .trailing)
                    .font(.footnote)
                    .foregroundColor(.gray)

                ForEach(heartZoneGraphViewModel.zoneMargins ?? [], id: \.self) { margin in
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
                        bpm.color.toColor(), style: StrokeStyle(lineWidth: 2.25, lineCap: .butt, lineJoin: .round)
                    )
                }
                .id(UUID())
            }
            .focusable(true)
            .digitalCrownRotation(
                $heartZoneGraphViewModel.crown, from: kMinimumCrownValue,
                through: kMaximumCrownValue, by: 0.1, sensitivity: .low,
                isContinuous: false, isHapticFeedbackEnabled: false
            )
            .onAppear(perform: { self.heartZoneGraphViewModel.isScreenVisible = true })
            .onDisappear(perform: { self.heartZoneGraphViewModel.isScreenVisible = false })
        }
    }
}

struct HeartZoneGraphView_Previews: PreviewProvider {
    static var previews: some View {
        HeartZoneGraphView(
            heartZoneGraphViewModel: HeartZoneGraphViewModel(
                healthKitService: HealthKitService(),
                workoutService: WorkoutService(locationManager: LocationManager(),
                                               healthKitService: HealthKitService(),
                                               settingsService: SettingsService(
                                                   settingsRepository: SettingsRepository(),
                                                   healthKitService: HealthKitService()
                                               ), zoneStatisticsCalculator:
                                               ZoneStatisticsCalculator(
                                                   settingsService:
                                                   SettingsService(settingsRepository:
                                                       SettingsRepository(), healthKitService: HealthKitService()))),
                settingsService: SettingsService(
                    settingsRepository: SettingsRepository(),
                    healthKitService: HealthKitService()
                )
            ))
    }
}
