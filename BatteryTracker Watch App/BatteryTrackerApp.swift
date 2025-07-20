//
//  BatteryTrackerApp.swift
//  BatteryTracker Watch App
//
//  Created by Simon Roberts on 19/07/2025.
//

import SwiftUI

@main
struct BatteryTrackerApp: App {
    @StateObject var batteryVM = BatteryViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(batteryVM)
        }
    }
}
