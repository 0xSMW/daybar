//
//  PreferencesView.swift
//  DayBar
//

import SwiftUI

struct PreferencesView: View {
    @ObservedObject var settings = SettingsStore.shared
    @State private var currentDate = Date()
    @State private var timer: Timer?
    
    var isValidPattern: Bool {
        DatePatternFormatter.validate(pattern: settings.dateFormat)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Format section
            VStack(alignment: .leading, spacing: 6) {
                Text("Date Format:")
                    .font(.system(size: 12, weight: .medium))
                
                TextField("Format pattern", text: $settings.dateFormat)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12, design: .monospaced))
                
                if isValidPattern {
                    HStack(spacing: 4) {
                        Text("Preview:")
                            .foregroundColor(.secondary)
                        Text(DatePatternFormatter.format(date: currentDate, pattern: settings.dateFormat))
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 11))
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Invalid format string. Falling back to default pattern.")
                            .foregroundColor(.secondary)
                    }
                    .font(.system(size: 11))
                }
            }
            
            Divider()
            
            // Options section
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Show icon in menu bar", isOn: $settings.showsIcon)
                    .toggleStyle(.checkbox)
                
                Toggle("Launch at login", isOn: $settings.launchesAtLogin)
                    .toggleStyle(.checkbox)
                
                if let error = settings.launchAtLoginError {
                    Text("Launch at login error: \(error)")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                }
            }
            
            Divider()
            
            // Presets / Pattern Reference
            VStack(alignment: .leading, spacing: 6) {
                Text("Common Format Patterns:")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 4) {
                    formatExample("E h:mm a", example: "Thu 4:08 PM")
                    formatExample("EEE, MMM d, h:mm a", example: "Thu, Jul 23, 4:08 PM")
                    formatExample("yyyy-MM-dd HH:mm:ss", example: "2026-07-23 16:08:03")
                    formatExample("h:mm:ss a", example: "4:08:03 PM")
                }
            }
        }
        .padding(20)
        .frame(width: 350)
        .onAppear {
            currentDate = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentDate = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func formatExample(_ pattern: String, example: String) -> some View {
        Button(action: {
            settings.dateFormat = pattern
        }) {
            HStack {
                Text(pattern)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.accentColor)
                Spacer()
                Text(example)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
