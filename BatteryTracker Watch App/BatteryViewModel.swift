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
    @Published var logInterval: TimeInterval {
        didSet {
            UserDefaults.standard.set(logInterval, forKey: intervalKey)
            restartTimer()
        }
    }

    private let maxHistoryDuration: TimeInterval = 24 * 60 * 60 // 24 hours

    private(set) var timer: Timer?
    private let historyKey = "batteryHistory"
    private let intervalKey = "logInterval"

    init(skipInitialLog: Bool = false) {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        self.batteryLevel = WKInterfaceDevice.current().batteryLevel
        self.batteryState = WKInterfaceDevice.current().batteryState
        let savedInterval = UserDefaults.standard.double(forKey: intervalKey)
        self.logInterval = savedInterval == 0 ? 600 : savedInterval
        loadHistory()
        if !skipInitialLog {
            logBatteryEntry()
        }
        startTimer()
    }

    deinit {
        timer?.invalidate()
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: logInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.batteryLevel = WKInterfaceDevice.current().batteryLevel
            self.batteryState = WKInterfaceDevice.current().batteryState
            self.logBatteryEntry()
        }
    }

    private func restartTimer() {
        timer?.invalidate()
        startTimer()
    }

    func logBatteryEntry() {
        let entry = BatteryEntry(
            timestamp: Date(),
            level: WKInterfaceDevice.current().batteryLevel,
            state: WKInterfaceDevice.current().batteryState
        )
        let cutoff = Date().addingTimeInterval(-maxHistoryDuration)
        history = (history + [entry]).filter { $0.timestamp >= cutoff }
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
            let cutoff = Date().addingTimeInterval(-maxHistoryDuration)
            history = decoded.filter { $0.timestamp >= cutoff }
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
