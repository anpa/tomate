//
//  PomodoroTimer.swift
//  Tomate
//
//  Created by André Alves on 01/09/2026.
//

import AppKit
import Foundation

enum SessionKind: Equatable {
    case focus
    case shortBreak
    case longBreak

    var duration: TimeInterval {
        switch self {
        case .focus: 25 * 60
        case .shortBreak: 5 * 60
        case .longBreak: 30 * 60
        }
    }

    var isBreak: Bool {
        self != .focus
    }
}

@Observable
final class PomodoroTimer {
    static let cyclesPerSequence = 4

    private(set) var cycle = 1
    private(set) var kind: SessionKind = .focus
    private(set) var remaining: TimeInterval = SessionKind.focus.duration
    private(set) var isRunning = false

    var progress: CGFloat {
        let duration = kind.duration
        guard duration > 0 else { return 0 }
        return CGFloat(remaining / duration)
    }

    var timeString: String {
        let total = max(0, Int(remaining))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var menuBarTitle: String {
        timeString
    }

    var phaseTitle: String {
        switch kind {
        case .focus:
            return "Focus \(cycle) of \(Self.cyclesPerSequence)"
        case .shortBreak:
            return "Break \(cycle) of \(Self.cyclesPerSequence)"
        case .longBreak:
            return "Long break"
        }
    }

    var statusTitle: String {
        if isRunning { return "Remaining" }
        if remaining < kind.duration { return "Paused" }
        return kind.isBreak ? "Start when ready" : "Ready"
    }

    var isFocusComplete: (Int) -> Bool {
        { completedCycle in
            if completedCycle < self.cycle { return true }
            if completedCycle == self.cycle { return self.kind.isBreak }
            return false
        }
    }

    var isBreakComplete: (Int) -> Bool {
        { completedCycle in
            completedCycle < self.cycle
        }
    }

    func isCurrentFocus(_ cycleNumber: Int) -> Bool {
        cycleNumber == cycle && kind == .focus
    }

    func isCurrentBreak(_ cycleNumber: Int) -> Bool {
        cycleNumber == cycle && kind.isBreak
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
        advance(playSound: false)
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
        advance(playSound: true)
    }

    private func advance(playSound: Bool) {
        if playSound {
            NSSound.beep()
        }

        switch kind {
        case .focus:
            kind = cycle == Self.cyclesPerSequence ? .longBreak : .shortBreak
        case .shortBreak:
            cycle += 1
            kind = .focus
        case .longBreak:
            cycle = 1
            kind = .focus
        }

        remaining = kind.duration
        isRunning = false
    }

    private func beginBackgroundActivity() {
        guard backgroundActivity == nil else { return }
        backgroundActivity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep, .suddenTerminationDisabled],
            reason: "Pomodoro session countdown"
        )
    }

    private func endBackgroundActivity() {
        if let backgroundActivity {
            ProcessInfo.processInfo.endActivity(backgroundActivity)
            self.backgroundActivity = nil
        }
    }
}
