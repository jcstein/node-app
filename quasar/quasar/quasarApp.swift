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
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 800, height: 650))
        }
    }
}
