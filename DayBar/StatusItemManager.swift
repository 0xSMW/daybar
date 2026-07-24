//
//  StatusItemManager.swift
//  DayBar
//

import AppKit
import SwiftUI
import Combine

@MainActor
final class StatusItemManager: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var settings = SettingsStore.shared
    
    private let calendarMenuItem = NSMenuItem()
    private lazy var calendarHostingView: NSHostingView<CalendarMenuView> = {
        let view = NSHostingView(rootView: CalendarMenuView())
        view.frame = NSRect(x: 0, y: 0, width: 220, height: 215)
        return view
    }()
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let menu = NSMenu()
        menu.delegate = self
        
        // Calendar custom menu item
        calendarMenuItem.view = calendarHostingView
        menu.addItem(calendarMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Preferences...
        let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)
        
        // Date & Time...
        let dateTimeItem = NSMenuItem(title: "Date & Time…", action: #selector(openSystemDateTime), keyEquivalent: "")
        dateTimeItem.target = self
        menu.addItem(dateTimeItem)
        
        // About DayBar
        let aboutItem = NSMenuItem(title: "About DayBar", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit DayBar
        let quitItem = NSMenuItem(title: "Quit DayBar", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        
        // Observe settings changes
        settings.$dateFormat
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)
            
        settings.$showsIcon
            .sink { [weak self] _ in self?.updateDisplay() }
            .store(in: &cancellables)
            
        // System event listeners
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: .NSSystemClockDidChange)
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in self?.scheduleUpdate() }
            .store(in: &cancellables)
            
        scheduleUpdate()
    }
    
    private lazy var cachedCalendarImage: NSImage? = {
        let image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
        image?.isTemplate = true
        return image
    }()
    
    func scheduleUpdate() {
        timer?.invalidate()
        updateDisplay()
        
        let interval = DatePatternFormatter.nextUpdateInterval(for: settings.dateFormat)
        let granularity = DatePatternFormatter.granularity(for: settings.dateFormat)
        
        let newTimer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.scheduleUpdate()
            }
        }
        
        // Coalesce timers for power efficiency
        switch granularity {
        case .seconds: newTimer.tolerance = 0.05
        case .minutes: newTimer.tolerance = 0.5
        case .daily: newTimer.tolerance = 1.0
        }
        
        RunLoop.main.add(newTimer, forMode: .common)
        self.timer = newTimer
    }
    
    private func updateDisplay() {
        guard let button = statusItem?.button else { return }
        
        let formattedText = DatePatternFormatter.format(date: Date(), pattern: settings.dateFormat)
        if button.title != formattedText {
            button.title = formattedText
        }
        
        if settings.showsIcon {
            if button.image == nil {
                button.image = cachedCalendarImage
                button.imagePosition = .imageLeft
            }
        } else {
            if button.image != nil {
                button.image = nil
            }
        }
    }
    
    // NSMenuDelegate: reset calendar state to Today when menu opens
    func menuWillOpen(_ menu: NSMenu) {
        calendarHostingView.rootView = CalendarMenuView()
    }
    
    @objc private func openPreferences() {
        WindowManager.shared.showPreferences()
    }
    
    @objc private func openSystemDateTime() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.datetime") {
            NSWorkspace.shared.open(url)
        } else if let url = URL(string: "x-apple.systempreferences:") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func openAbout() {
        WindowManager.shared.showAbout()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
