//
//  BatteryChartView.swift
//  BatteryTracker
//
//  Created by Simon Roberts on 19/07/2025.
//


import SwiftUI
import Charts

struct BatteryChartView: View {
    var history: [BatteryEntry]

    var body: some View {
        let now = Date()
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now) ?? now
        Chart(history) { entry in
            LineMark(
                x: .value("Time", entry.timestamp),
                y: .value("Battery %", entry.level * 100)
            )
            .foregroundStyle(.green)
        }
        .chartYScale(domain: 0...100)
        .chartXScale(domain: twentyFourHoursAgo...now)
        .frame(height: 120)
        .padding(.vertical)
        .padding(.horizontal, 4)
    }
}
