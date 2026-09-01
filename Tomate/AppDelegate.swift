//
//  AppDelegate.swift
//  Tomate
//
//  Created by André Alves on 01/09/2026.
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let timer = PomodoroTimer()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
