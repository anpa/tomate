//
//  TomateApp.swift
//  Tomate
//
//  Created by André Alves on 01/09/2026.
//

import SwiftUI

@main
struct TomateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(appDelegate.timer)
        } label: {
            MenuBarTimerLabel(timer: appDelegate.timer)
        }
        .menuBarExtraStyle(.window)
    }
}

private struct MenuBarTimerLabel: View {
    var timer: PomodoroTimer

    var body: some View {
        Text(timer.timeString)
            .monospacedDigit()
            .font(.system(size: 13, weight: .semibold, design: .rounded))
    }
}
