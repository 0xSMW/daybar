//
//  DaybarApp.swift
//  Daybar
//

import SwiftUI
import AppKit

@main
struct DaybarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemManager: StatusItemManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItemManager = StatusItemManager()
        statusItemManager?.setupStatusItem()
    }
}
