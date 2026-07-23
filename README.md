# DayBar

DayBar is a clean, lightweight macOS menu-bar clock and calendar replacement written in Swift 6 and AppKit with selective SwiftUI. Built as a dedicated agent application, it lives exclusively in your menu bar without occupying space in the Dock, providing custom ICU date formatting, instant month-at-a-glance navigation, and zero background overhead or network permissions.

## Features

- **Customizable Menu-Bar Clock**: Format date and time display using standard ICU pattern strings (e.g., `E h:mm a`, `yyyy-MM-dd HH:mm:ss`) with live pattern validation and optional monochrome calendar icon.
- **Smart Timer Scheduling**: Automatically adjusts update frequencies—firing once per second when seconds are displayed, once per minute otherwise, or at midnight—while re-aligning on system wake, time-zone, or locale changes.
- **Compact 6-Week Calendar Grid**: Interactive pop-down calendar following your system locale and first-day-of-week regional settings. Includes current month dates, adjacent month dates, today highlight, and one-click return to today.
- **Launch at Login Integration**: Native macOS login-item management using `SMAppService.mainApp` (macOS 13+).
- **Native Preferences & About Windows**: Clean, single-instance `NSWindow` dialogs for adjusting settings, viewing live previews, and inspecting app metadata.
- **Quick System Access**: Direct menu shortcut to open macOS System Settings Date & Time pane (`x-apple.systempreferences:`).

## How to Build and Install

### Prerequisites

- macOS 15.0 (Sequoia) or later
- Xcode 16.0 or later with Swift 6 support

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/daybar.git
   cd daybar
   ```

2. Build the app using `xcodebuild`:
   ```bash
   xcodebuild -project DayBar.xcodeproj -scheme DayBar -configuration Release build
   ```

3. Locate the built application bundle in Xcode's DerivedData or build folder:
   ```bash
   open ~/Library/Developer/Xcode/DerivedData/DayBar-*/Build/Products/Release/
   ```

### Installing

1. Drag `DayBar.app` into your `/Applications` folder.
2. Double-click `DayBar.app` to launch it. The app will immediately appear in your macOS menu bar.
3. (Optional) Open **Preferences…** from the DayBar menu and check **Launch at login** to automatically start DayBar when you log in.

## License

This project is licensed under the MIT License - see the [LICENSE](file:///Users/stephenwalker/Code/projects/daybar/LICENSE) file for details.

