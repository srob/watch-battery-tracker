import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = BatteryViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Battery Tracker")
                    .font(.headline)

                Text("Current Level: \(Int(viewModel.batteryLevel * 100))%")
                Text("Current State: \(stateDescription(viewModel.batteryState))")

                Divider()

                Text("Battery History")
                    .font(.subheadline)
                    .padding(.top, 4)

                BatteryChartView(history: viewModel.history)

                if viewModel.history.isEmpty {
                    Text("No battery history yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.history.reversed(), id: \.id) { entry in
                        HStack {
                            Text(entry.timestamp, style: .time)
                                .font(.footnote)
                            Spacer()
                            Text("\(Int(entry.level * 100))%")
                                .font(.footnote)
                            Text(stateDescription(entry.state))
                                .font(.footnote)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

private func stateDescription(_ state: WKInterfaceDeviceBatteryState) -> String {
    switch state {
    case .charging:
        return "Charging"
    case .unplugged:
        return "Unplugged"
    case .full:
        return "Full"
    default:
        return "Unknown"
    }
}
