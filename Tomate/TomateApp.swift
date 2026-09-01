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
            Label {
                Text(appDelegate.timer.menuBarTitle)
            } icon: {
                Image("MenuBarIcon")
                    .renderingMode(.original)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
