//
//  AppDelegate.swift
//  GPMac
//
//  Created by user on 2019/12/06.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var window = NSWindowController(window: NSWindow(contentViewController: ViewController()))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window.showWindow(self)
        return true
    }

}

