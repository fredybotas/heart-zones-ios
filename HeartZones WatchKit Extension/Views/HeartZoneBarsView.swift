//
//  HeartZoneBarsView.swift
//  HeartZones WatchKit Extension
//
//  Created by Michal Manak - personal on 17/01/2022.
//

import SwiftUI

struct HeartZoneBarView: View {
    let color: Color
    let leftText: String
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(color)
            HStack(spacing: 0) {
                Text(leftText)
                    .font(
                        Font.system(size: 16, weight: .semibold, design: .default)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(alignment: .leading)
                    .padding(-4)
            }
            .padding([.leading, .trailing], 8)
        }
    }
}

struct HeartZoneBarsView: View {
    @ObservedObject var heartZoneBarsViewModel: HeartZoneBarsViewModel
    private let spacingGap: CGFloat = 4

    private func getHeightOffset(_ geo: GeometryProxy) -> CGFloat {
        print(geo.size)
        if geo.size.height < 150 {
            return 10
        }
        return -20
    }

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: spacingGap) {
                ForEach(heartZoneBarsViewModel.bars, id: \.self) { bar in
                    HeartZoneBarView(color: bar.color, leftText: bar.percentageString)
                        .frame(width: bar.percentage * (geo.size.width - 10),
                               height: (geo.size.height -
                                   24 -
                                   (CGFloat(heartZoneBarsViewModel.bars.count - 1) * spacingGap)) /
                                   CGFloat(heartZoneBarsViewModel.bars.count))
                }
            }
            .padding(5)
        }
        .edgesIgnoringSafeArea([.bottom])
        .onAppear(perform: { self.heartZoneBarsViewModel.isScreenVisible = true })
        .onDisappear(perform: { self.heartZoneBarsViewModel.isScreenVisible = false })
    }
}

class SettingsServiceFake: ISettingsService {
    var zonesCount: Int = 4

    func resetHeartZoneSettings() {
        selectedHeartZoneSetting = HeartZonesSetting.getDefaultHeartZonesSetting()
        maximumBpm = 195
        targetZoneId = 2
    }

    var targetZoneId: Int = 2
    var selectedHeartZoneSetting: HeartZonesSetting = .getDefaultHeartZonesSetting()
    var heartZonesAlertEnabled: Bool = true
    var targetHeartZoneAlertEnabled: Bool = true
    var maximumBpm: Int = 195
    var selectedDistanceMetric: DistanceMetric = DistanceMetric.getDefault(metric: true)
    var selectedEnergyMetric: EnergyMetric = .getDefault()
    var selectedSpeedMetric: SpeedMetric = .getDefault()
    var selectedMetricInFieldOne: WorkoutMetric = .getDefaultForFieldOne()
    var selectedMetricInFieldTwo: WorkoutMetric = .getDefaultForFieldTwo()
}

struct HeartZoneBarsView_Previews: PreviewProvider {
    static var previews: some View {
        HeartZoneBarsView(heartZoneBarsViewModel: HeartZoneBarsViewModel(
            settingsService:
            SettingsServiceFake(),
            workoutService: WorkoutService(
                locationManager: LocationManager(),
                healthKitService: HealthKitService(),
                settingsService: SettingsService(
                    settingsRepository: SettingsRepository(),
                    healthKitService: HealthKitService()
                ),
                zoneStatisticsCalculator: ZoneStatisticsCalculator(
                    settingsService:
                    SettingsService(settingsRepository: SettingsRepository(),
                                    healthKitService: HealthKitService()))
            )
        ))
    }
}
