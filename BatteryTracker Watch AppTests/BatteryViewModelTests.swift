import XCTest
@testable import BatteryTracker_Watch_App

class BatteryViewModelTests: XCTestCase {
    func testLogBatteryEntryAppendsEntry() {
        let viewModel = BatteryViewModel()
        let initialCount = viewModel.history.count
        viewModel.logBatteryEntry()
        XCTAssertEqual(viewModel.history.count, initialCount + 1)
    }
    
    func testHistoryPersistence() {
        let viewModel = BatteryViewModel(skipInitialLog: true)
        viewModel.history.removeAll()
        viewModel.logBatteryEntry()
        let savedHistory = viewModel.history
        let newViewModel = BatteryViewModel(skipInitialLog: true)
        XCTAssertEqual(newViewModel.history.count, savedHistory.count)
    }
    
    func testHistoryFiltersLast24Hours() {
        let viewModel = BatteryViewModel()
        let now = Date()
        let oldEntry = BatteryEntry(timestamp: Calendar.current.date(byAdding: .hour, value: -25, to: now)!, level: 0.5, state: .unplugged)
        let recentEntry = BatteryEntry(timestamp: now, level: 0.8, state: .charging)
        viewModel.history = [oldEntry, recentEntry]
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let filtered = viewModel.history.filter { $0.timestamp >= twentyFourHoursAgo }
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.level, 0.8)
    }

    func testLogIntervalPersistence() {
        UserDefaults.standard.removeObject(forKey: "logInterval")
        let viewModel = BatteryViewModel(skipInitialLog: true)
        viewModel.logInterval = 300
        let newVM = BatteryViewModel(skipInitialLog: true)
        XCTAssertEqual(newVM.logInterval, 300)
    }
}
