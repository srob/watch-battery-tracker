import WidgetKit
import SwiftUI
import WatchKit

struct BatteryWidgetEntry: TimelineEntry {
    let date: Date
    let level: Float
}

struct BatteryProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryWidgetEntry {
        BatteryWidgetEntry(date: Date(), level: WKInterfaceDevice.current().batteryLevel)
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryWidgetEntry) -> ()) {
        let entry = BatteryWidgetEntry(date: Date(), level: WKInterfaceDevice.current().batteryLevel)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryWidgetEntry>) -> ()) {
        let level = WKInterfaceDevice.current().batteryLevel
        let entry = BatteryWidgetEntry(date: Date(), level: level)
        let refresh = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date().addingTimeInterval(600)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct BatteryWidgetView : View {
    var entry: BatteryProvider.Entry

    var body: some View {
        Gauge(value: Double(entry.level), in: 0...1) {
            Text("Battery")
        } currentValueLabel: {
            Text("\(Int(entry.level * 100))%")
        }
        .gaugeStyle(.accessoryCircular)
        .tint(entry.level < 0.2 ? .red : .green)
    }
}

@main
struct BatteryWidget: Widget {
    let kind: String = "BatteryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryProvider()) { entry in
            BatteryWidgetView(entry: entry)
        }
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
        .configurationDisplayName("Battery Level")
        .description("Shows current battery level and turns red when low.")
    }
}
