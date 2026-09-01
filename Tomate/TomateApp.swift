//
//  TomateApp.swift
//  Tomate
//
//  Created by André Alves on 01/09/2026.
//

import SwiftUI

@main
struct TomateApp: App {
    @State private var timer = PomodoroTimer()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(timer)
        } label: {
            Label(timer.menuBarTitle, systemImage: timer.isRunning ? "tomato.fill" : "tomato")
        }
        .menuBarExtraStyle(.window)
    }
}
