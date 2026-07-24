# Daybar

Daybar is a lightweight macOS menu-bar clock and calendar written in Swift with AppKit and SwiftUI. It runs as an accessory app without a Dock icon and provides custom ICU date formatting, a compact month calendar, optional launch at login, and no network entitlement.

<img width="474" height="371" alt="image" src="https://github.com/user-attachments/assets/5a1db787-12e6-441c-8d19-f221c293a10e" />

## Features

- **Customizable Menu-Bar Clock**: Format the date and time using ICU pattern strings (e.g., `E h:mm a`, `yyyy-MM-dd HH:mm:ss`) with a live preview, fallback for empty patterns, and an optional monochrome calendar icon.
- **Smart Timer Scheduling**: Aligns updates to the next second, minute, or midnight according to the active format, then reschedules after system wake, clock, time-zone, or locale changes.
- **Compact 6-Week Calendar Grid**: Interactive pop-down calendar following your system locale and first-day-of-week regional settings. Includes current month dates, adjacent month dates, today highlight, and one-click return to today.
- **Launch at Login Integration**: Native macOS login-item management using `SMAppService.mainApp`.
- **Native Preferences & About Windows**: Clean, single-instance `NSWindow` dialogs for adjusting settings, viewing live previews, and inspecting app metadata.
- **Quick System Access**: Menu item for opening the macOS System Settings Date & Time pane.

## How to Build and Install

### Prerequisites

- macOS 15.0 (Sequoia) or later
- Xcode 16.0 or later

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/0xSMW/daybar.git
   cd daybar
   ```

2. Build the app using `xcodebuild`:
   ```bash
   xcodebuild -project Daybar.xcodeproj -scheme Daybar -configuration Release build
   ```

3. Locate the built application bundle in Xcode's DerivedData or build folder:
   ```bash
   open ~/Library/Developer/Xcode/DerivedData/Daybar-*/Build/Products/Release/
   ```

### Installing

1. Drag `Daybar.app` into your `/Applications` folder.
2. Double-click `Daybar.app` to launch it. The app will immediately appear in your macOS menu bar.
3. (Optional) Open **Preferences…** from the Daybar menu and check **Launch at login** to automatically start Daybar when you log in.
