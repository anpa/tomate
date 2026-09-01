//
//  PomodoroTimer.swift
//  Tomate
//
//  Created by André Alves on 01/09/2026.
//

import AppKit
import Foundation

@Observable
final class PomodoroTimer {
    static let focusDuration: TimeInterval = 25 * 60

    private(set) var remaining: TimeInterval = PomodoroTimer.focusDuration
    private(set) var isRunning = false

    var progress: CGFloat {
        CGFloat(remaining / Self.focusDuration)
    }

    var timeString: String {
        let total = max(0, Int(remaining))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var menuBarTitle: String {
        if isRunning || remaining < Self.focusDuration {
            return timeString
        }
        return "Tomate"
    }

    private var endDate: Date?
    private var tickTask: Task<Void, Never>?
    private var backgroundActivity: NSObjectProtocol?

    func toggle() {
        isRunning ? pause() : play()
    }

    func play() {
        guard !isRunning, remaining > 0 else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(remaining)
        beginBackgroundActivity()
        startTicking()
    }

    func pause() {
        tick()
        isRunning = false
        endDate = nil
        tickTask?.cancel()
        tickTask = nil
        endBackgroundActivity()
    }

    func skip() {
        pause()
        remaining = Self.focusDuration
    }

    private func startTicking() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.tick()
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        remaining = max(0, endDate.timeIntervalSinceNow)
        if remaining <= 0 {
            completeSession()
        }
    }

    private func completeSession() {
        remaining = 0
        isRunning = false
        endDate = nil
        tickTask?.cancel()
        tickTask = nil
        endBackgroundActivity()
        NSSound.beep()
        remaining = Self.focusDuration
    }

    private func beginBackgroundActivity() {
        guard backgroundActivity == nil else { return }
        backgroundActivity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep, .suddenTerminationDisabled],
            reason: "Focus session countdown"
        )
    }

    private func endBackgroundActivity() {
        if let backgroundActivity {
            ProcessInfo.processInfo.endActivity(backgroundActivity)
            self.backgroundActivity = nil
        }
    }
}
