import Combine
import SwiftUI

struct IntervalTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mode: TimerMode = .work
    @State private var secondsRemaining = 45
    @State private var isRunning = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum TimerMode: String, CaseIterable, Identifiable {
        case work = "WORK · 45 SEC"
        case rest = "REST · 2 MIN"
        var id: String { rawValue }
        var duration: Int { self == .work ? 45 : 120 }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                SectionLabel(text: "Interval timer")

                Picker("Timer mode", selection: $mode) {
                    ForEach(TimerMode.allCases) { mode in Text(mode.rawValue).tag(mode) }
                }
                .pickerStyle(.segmented)
                .onChange(of: mode) { _, newMode in reset(to: newMode.duration) }

                VStack(spacing: 10) {
                    Text(mode == .work ? "KEEP MOVING" : "BREATHE + RESET")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(1.8)
                    Text(formattedTime)
                        .font(.system(size: 78, weight: .black, design: .monospaced))
                        .tracking(-7)
                }
                .frame(maxWidth: .infinity, minHeight: 230)
                .background(isRunning ? S5Theme.red : S5Theme.panel)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .animation(.easeInOut(duration: 0.2), value: isRunning)

                HStack(spacing: 10) {
                    TimerButton(title: "RESET", systemImage: "arrow.counterclockwise") { reset(to: mode.duration) }
                    Button {
                        if secondsRemaining == 0 { secondsRemaining = mode.duration }
                        isRunning.toggle()
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(S5Theme.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    TimerButton(title: "+10", systemImage: "plus") { secondsRemaining += 10 }
                }

                Spacer()
            }
            .padding(20)
            .background(S5Theme.black)
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.bold)
                }
            }
            .toolbarBackground(S5Theme.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onReceive(timer) { _ in
                guard isRunning else { return }
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    isRunning = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var formattedTime: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    private func reset(to duration: Int) {
        isRunning = false
        secondsRemaining = duration
    }
}

private struct TimerButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title).font(.system(size: 9, weight: .bold, design: .monospaced))
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(S5Theme.panel)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
