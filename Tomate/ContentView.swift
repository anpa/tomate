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
        VStack(spacing: 22) {
            VStack(spacing: 8) {
                Image("Tomato")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 32, height: 32)

                Text("Focus")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(1.4)
                    .textCase(.uppercase)
            }

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.18), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        Color.tomato,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: timer.progress)

                VStack(spacing: 4) {
                    Text(timer.timeString)
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    Text(timer.isRunning ? "Remaining" : "Ready")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 188, height: 188)
            .padding(14)
            .glassEffect(.regular, in: Circle())

            GlassEffectContainer(spacing: 14) {
                HStack(spacing: 14) {
                    Button("Play", systemImage: timer.isRunning ? "pause.fill" : "play.fill") {
                        timer.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glassProminent)
                    .tint(.tomato)
                    .controlSize(.large)
                    .help(timer.isRunning ? "Pause" : "Play")

                    Button("Skip", systemImage: "forward.end.fill") {
                        timer.skip()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .help("Skip session")
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

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

private extension Color {
    static let tomato = Color(red: 0.93, green: 0.33, blue: 0.27)
}

#Preview {
    ContentView()
        .environment(PomodoroTimer())
}
