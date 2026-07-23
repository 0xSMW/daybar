//
//  WindowManager.swift
//  DayBar
//

import AppKit
import SwiftUI

@MainActor
final class WindowManager {
    static let shared = WindowManager()
    
    private var preferencesWindow: NSWindow?
    private var aboutWindow: NSWindow?
    
    func showPreferences() {
        if let window = preferencesWindow {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let contentView = PreferencesView()
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "DayBar Preferences"
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false
        
        self.preferencesWindow = window
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    func showAbout() {
        if let window = aboutWindow {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let contentView = AboutView()
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About DayBar"
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false
        
        self.aboutWindow = window
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
