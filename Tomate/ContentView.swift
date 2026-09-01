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
                    .frame(width: 36, height: 36)

                Text("Focus")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .tracking(1.4)
                    .textCase(.uppercase)
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.07), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        Color.tomato,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color.tomato.opacity(0.35), radius: 8, y: 0)
                    .animation(.linear(duration: 0.2), value: timer.progress)

                VStack(spacing: 6) {
                    Text(timer.timeString)
                        .font(.system(size: 38, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    Text(timer.isRunning ? "Remaining" : "Ready")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(width: 196, height: 196)

            HStack(spacing: 16) {
                Button(action: timer.toggle) {
                    Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(Color.tomato, in: Circle())
                }
                .buttonStyle(.plain)
                .help(timer.isRunning ? "Pause" : "Play")

                ControlButton(
                    systemName: "forward.end.fill",
                    help: "Skip session",
                    action: timer.skip
                )
            }

            Button("Quit", action: quit)
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.28))
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 18)
        .frame(width: 280)
        .background(Color.popoverBackground)
        .preferredColorScheme(.dark)
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

private struct ControlButton: View {
    let systemName: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.08), in: Circle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}

private extension Color {
    static let tomato = Color(red: 0.93, green: 0.33, blue: 0.27)
    static let popoverBackground = Color(red: 0.09, green: 0.09, blue: 0.10)
}

#Preview {
    ContentView()
        .environment(PomodoroTimer())
}
