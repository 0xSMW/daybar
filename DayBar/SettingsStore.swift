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
        static let launchesAtLogin = "launchesAtLogin"
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
            UserDefaults.standard.set(launchesAtLogin, forKey: Keys.launchesAtLogin)
            updateLaunchAtLogin(enabled: launchesAtLogin)
        }
    }
    
    @Published var launchAtLoginError: String? = nil
    
    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Keys.dateFormat: "E h:mm a",
            Keys.showsIcon: true,
            Keys.launchesAtLogin: false
        ])
        
        self.dateFormat = defaults.string(forKey: Keys.dateFormat) ?? "E h:mm a"
        self.showsIcon = defaults.bool(forKey: Keys.showsIcon)
        
        if #available(macOS 13.0, *) {
            self.launchesAtLogin = (SMAppService.mainApp.status == .enabled)
        } else {
            self.launchesAtLogin = defaults.bool(forKey: Keys.launchesAtLogin)
        }
    }
    
    private func updateLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
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
                launchAtLoginError = error.localizedDescription
                // Sync back state on failure
                self.launchesAtLogin = (SMAppService.mainApp.status == .enabled)
            }
        }
    }
}
