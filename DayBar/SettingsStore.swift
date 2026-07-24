//
//  SettingsStore.swift
//  DayBar
//

import Foundation
import ServiceManagement
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    private enum Keys {
        static let dateFormat = "dateFormat"
        static let showsIcon = "showsIcon"
    }
    
    @Published var dateFormat: String {
        didSet {
            UserDefaults.standard.set(dateFormat, forKey: Keys.dateFormat)
        }
    }
    
    @Published var showsIcon: Bool {
        didSet {
            UserDefaults.standard.set(showsIcon, forKey: Keys.showsIcon)
        }
    }
    
    @Published var launchesAtLogin: Bool {
        didSet {
            guard !isSynchronizingLaunchAtLogin else { return }
            updateLaunchAtLogin(enabled: launchesAtLogin)
        }
    }
    
    @Published var launchAtLoginError: String? = nil
    private var isSynchronizingLaunchAtLogin = false
    
    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Keys.dateFormat: DatePatternFormatter.defaultPattern,
            Keys.showsIcon: true
        ])
        
        self.dateFormat = defaults.string(forKey: Keys.dateFormat) ?? DatePatternFormatter.defaultPattern
        self.showsIcon = defaults.bool(forKey: Keys.showsIcon)
        self.launchesAtLogin = (SMAppService.mainApp.status == .enabled)
    }
    
    private func updateLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            launchAtLoginError = nil
        } catch {
            let errorMessage = error.localizedDescription

            isSynchronizingLaunchAtLogin = true
            launchesAtLogin = (SMAppService.mainApp.status == .enabled)
            isSynchronizingLaunchAtLogin = false

            launchAtLoginError = errorMessage
        }
    }
}
