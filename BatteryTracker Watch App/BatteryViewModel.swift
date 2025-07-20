//
//  BatteryViewModel.swift
//  BatteryTracker
//
//  Created by Simon Roberts on 19/07/2025.
//


import Foundation
import WatchKit

class BatteryViewModel: ObservableObject {
    @Published var batteryLevel: Float = WKInterfaceDevice.current().batteryLevel
    @Published var batteryState: WKInterfaceDeviceBatteryState = WKInterfaceDevice.current().batteryState
    @Published var history: [BatteryEntry] = [] {
        didSet {
            saveHistory()
        }
    }

    private var timer: Timer?
    private let historyKey = "batteryHistory"

    init() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        self.batteryLevel = WKInterfaceDevice.current().batteryLevel
        self.batteryState = WKInterfaceDevice.current().batteryState
        loadHistory()
        logBatteryEntry()
        startTimer()
    }

    deinit {
        timer?.invalidate()
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.batteryLevel = WKInterfaceDevice.current().batteryLevel
            self.batteryState = WKInterfaceDevice.current().batteryState
            self.logBatteryEntry()
        }
    }

    func logBatteryEntry() {
        let entry = BatteryEntry(
            timestamp: Date(),
            level: WKInterfaceDevice.current().batteryLevel,
            state: WKInterfaceDevice.current().batteryState
        )
        history.append(entry)
    }

    // MARK: - Persistence

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([BatteryEntry].self, from: data) {
            history = decoded
        }
    }
}

struct BatteryEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let level: Float
    let state: WKInterfaceDeviceBatteryState

    enum CodingKeys: String, CodingKey {
        case id, timestamp, level, state
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(level, forKey: .level)
        try container.encode(state.rawValue, forKey: .state)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        level = try container.decode(Float.self, forKey: .level)
        let stateRawValue = try container.decode(Int.self, forKey: .state)
        state = WKInterfaceDeviceBatteryState(rawValue: stateRawValue) ?? .unknown
    }

    init(timestamp: Date, level: Float, state: WKInterfaceDeviceBatteryState) {
        self.id = UUID()
        self.timestamp = timestamp
        self.level = level
        self.state = state
    }
}
