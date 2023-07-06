//
//  quasarApp.swift
//  quasar
//
//  Created by Josh Stein on 6/1/23.
//

import SwiftUI

@main
struct node_appApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 733)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 800, height: 733))
            self.window = window
        }
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        self.window?.setContentSize(NSSize(width: 800, height: 733))
    }
}
