//
//  ContentView.swift
//  Tomate
//
//  Created by André Alves on 01/09/2026.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @Environment(PomodoroTimer.self) private var timer

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image("Tomato")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 32, height: 32)

                Text("TOMATE")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
            }

            SequenceIndicator(timer: timer)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.18), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        timer.kind.isBreak ? Color.breakAccent : Color.tomato,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: timer.progress)

                VStack(spacing: 4) {
                    Text(timer.timeString)
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    Text(timer.statusTitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 188, height: 188)
            .padding(14)
            .glassEffect(.regular, in: Circle())

            Text(timer.phaseTitle)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            // Intent row — shown only during focus sessions
            if timer.kind == .focus {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .foregroundStyle(.primary)
                        .font(.system(size: 11, weight: .medium))

                    TextField("What will you focus on?", text: intentBinding)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .rounded))
                        .disabled(timer.isRunning)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
            }

            GlassEffectContainer(spacing: 14) {
                HStack(spacing: 14) {
                    Button("Play", systemImage: timer.isRunning ? "pause.fill" : "play.fill") {
                        timer.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glassProminent)
                    .tint(timer.kind.isBreak ? Color.breakAccent : Color.tomato)
                    .controlSize(.large)
                    .help(playHelp)

                    Button("Skip", systemImage: "forward.end.fill") {
                        timer.skip()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .help(skipHelp)
                }
            }

            Button("Quit", action: quit)
                .buttonStyle(.glass)
                .controlSize(.small)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 26)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .frame(width: 280)
        .containerBackground(.clear, for: .window)
        .preferredColorScheme(.dark)
    }

    private var playHelp: String {
        if timer.isRunning { return "Pause" }
        if timer.kind.isBreak { return "Start break" }
        return "Play"
    }

    private var skipHelp: String {
        timer.kind.isBreak ? "Skip break" : "Skip session"
    }

    private var intentBinding: Binding<String> {
        Binding(
            get: { timer.intent },
            set: { timer.setIntent($0) }
        )
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

private struct SequenceIndicator: View {
    var timer: PomodoroTimer

    var body: some View {
        HStack(spacing: 14) {
            ForEach(1...PomodoroTimer.cyclesPerSequence, id: \.self) { cycleNumber in
                CycleColumn(
                    cycleNumber: cycleNumber,
                    isLongBreak: cycleNumber == PomodoroTimer.cyclesPerSequence,
                    focusState: focusState(for: cycleNumber),
                    breakState: breakState(for: cycleNumber)
                )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(timer.phaseTitle)
    }

    private func focusState(for cycleNumber: Int) -> StepState {
        if timer.isCurrentFocus(cycleNumber) { return .current }
        if timer.isFocusComplete(cycleNumber) { return .complete }
        return .upcoming
    }

    private func breakState(for cycleNumber: Int) -> StepState {
        if timer.isCurrentBreak(cycleNumber) { return .current }
        if timer.isBreakComplete(cycleNumber) { return .complete }
        return .upcoming
    }
}

private enum StepState {
    case upcoming, current, complete
}

private struct CycleColumn: View {
    let cycleNumber: Int
    let isLongBreak: Bool
    let focusState: StepState
    let breakState: StepState

    var body: some View {
        VStack(spacing: 6) {
            StepDot(state: focusState, accent: .tomato, size: CGSize(width: 9, height: 9))

            StepDot(
                state: breakState,
                accent: .breakAccent,
                size: CGSize(width: isLongBreak ? 16 : 7, height: 7)
            )

            Text("\(cycleNumber)")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(isCurrent ? .primary : .secondary)
        }
        .frame(width: 28)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cycle \(cycleNumber)")
    }

    private var isCurrent: Bool {
        focusState == .current || breakState == .current
    }
}

private struct StepDot: View {
    let state: StepState
    let accent: Color
    let size: CGSize

    var body: some View {
        Capsule()
            .fill(fill)
            .overlay {
                Capsule()
                    .stroke(stroke, lineWidth: state == .current ? 1.5 : 0)
            }
            .frame(width: size.width, height: size.height)
            .shadow(color: state == .current ? accent.opacity(0.55) : .clear, radius: 4)
    }

    private var fill: Color {
        switch state {
        case .upcoming: .white.opacity(0.16)
        case .current, .complete: accent
        }
    }

    private var stroke: Color {
        state == .current ? .white.opacity(0.85) : .clear
    }
}

private extension Color {
    static let tomato = Color(red: 0.93, green: 0.33, blue: 0.27)
    static let breakAccent = Color(red: 0.36, green: 0.72, blue: 0.58)
}

#Preview {
    ContentView()
        .environment(PomodoroTimer())
}
