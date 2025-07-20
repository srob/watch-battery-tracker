# Watch Battery Tracker

Watch Battery Tracker is a small Apple Watch application that logs your watch's
battery level over time and displays the history in a simple chart. It is built
with SwiftUI and targets watchOS.

## Features

- **Current Status** – shows the current battery percentage and charge state.
- **Background Logging** – records the battery level every 10 minutes and stores
  the history on device.
- **History View** – lists recent battery entries and displays a line chart for
  the last 24 hours.
- **SwiftUI** – entire interface is built using SwiftUI views.

## Requirements

- Xcode 15 or later
- watchOS 10 or later

## Getting Started

1. Clone the repository.
2. Open `BatteryTracker.xcodeproj` in Xcode.
3. Select the *BatteryTracker Watch App* scheme.
4. Build and run on an Apple Watch simulator or device.

### Running Tests

The project includes unit tests for `BatteryViewModel` and placeholder UI tests.
Tests can be executed from Xcode via **Product ▸ Test** (`⌘U`) or from the command
line:

```bash
xcodebuild test -scheme "BatteryTracker Watch App" -destination 'platform=watchOS Simulator,name=Any watchOS Simulator Device'
```

## Project Structure

- `BatteryTracker Watch App/` – main watch app sources, including SwiftUI views
  and the view model.
- `BatteryTracker Watch AppTests/` – unit test suite.
- `BatteryTracker Watch AppUITests/` – UI test targets.
- `.github/workflows/ci.yml` – GitHub Actions workflow that builds and tests the
  project on macOS runners.

## Battery Logging Implementation

`BatteryViewModel` monitors the watch's battery and appends a new `BatteryEntry`
(containing timestamp, charge level, and charging state) every 10 minutes. The
history is encoded with `JSONEncoder` and persisted using `UserDefaults`, so the
information is retained between launches.

## License

This project is released under the [MIT License](LICENSE).
