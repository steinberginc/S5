import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Binding var selectedDay: Int
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionLabel(text: "The full week")
                    Text("FIVE DAYS.\nONE CLEAR PLAN.")
                        .font(S5Type.display(52))
                        .tracking(-0.8)
                        .lineSpacing(-4)

                    Text("Each session pairs one focused strength block with a nine-move conditioning circuit.")
                        .foregroundStyle(S5Theme.secondary)

                    VStack(spacing: 8) {
                        ForEach(WorkoutData.workouts) { workout in
                            Button {
                                selectedDay = workout.id
                                selectedTab = 1
                            } label: {
                                HStack(spacing: 14) {
                                    Text("0\(workout.id)")
                                        .font(S5Type.data(24, weight: .black))
                                        .foregroundStyle(S5Theme.red)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(workout.kicker).font(.caption).foregroundStyle(S5Theme.secondary)
                                        Text(workout.focus.uppercased()).font(S5Type.display(24))
                                        Text("\(workout.strength.count) LIFTS + 9 CIRCUIT MOVES")
                                            .font(S5Type.data(9))
                                            .foregroundStyle(S5Theme.secondary)
                                    }
                                    Spacer()
                                    S5ProgressRing(progress: progressStore.completion(for: workout), size: 48)
                                }
                                .padding(14)
                                .background(S5Theme.panel)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        Text("SESSION RHYTHM").font(S5Type.display(22))
                        RhythmRow(number: "01", title: "Warm up", detail: "5–8 minutes of easy movement and ramp-up sets.")
                        RhythmRow(number: "02", title: "Lift", detail: "40–45 minutes. Add load only while reps stay crisp.")
                        RhythmRow(number: "03", title: "Condition", detail: "Three rounds. 45 seconds per move, two minutes between rounds.")
                    }
                    .padding(20)
                    .background(S5Theme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(18)
            }
            .background(S5Theme.black)
            .navigationTitle("Plan")
            .toolbarBackground(S5Theme.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

private struct RhythmRow: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number).font(S5Type.data(11, weight: .black)).foregroundStyle(S5Theme.red)
            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased()).font(S5Type.display(17))
                Text(detail).font(.caption).foregroundStyle(S5Theme.secondary)
            }
        }
    }
}

struct S5ProgressView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Binding var selectedDay: Int
    @Binding var selectedTab: Int
    @State private var showResetConfirmation = false

    private var totalExercises: Int {
        WorkoutData.workouts.reduce(0) { $0 + $1.allExercises.count }
    }

    private var totalCompletion: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(progressStore.completed.count) / Double(totalExercises)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionLabel(text: "Your momentum")
                    Text("PROOF\nOF WORK.")
                        .font(S5Type.display(60))
                        .tracking(-0.8)
                        .lineSpacing(-5)

                    HStack(spacing: 26) {
                        S5ProgressRing(progress: totalCompletion, size: 116)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(progressStore.completed.count)")
                                .font(S5Type.display(62))
                                .foregroundStyle(S5Theme.red)
                            Text("MOVEMENTS COMPLETE")
                                .font(S5Type.data(9))
                                .foregroundStyle(S5Theme.secondary)
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(S5Theme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(spacing: 8) {
                        ForEach(WorkoutData.workouts) { workout in
                            Button {
                                selectedDay = workout.id
                                selectedTab = 1
                            } label: {
                                HStack {
                                    Text("DAY 0\(workout.id)")
                                        .font(S5Type.data(9))
                                        .foregroundStyle(S5Theme.secondary)
                                        .frame(width: 66, alignment: .leading)
                                    Text(workout.focus.uppercased()).font(S5Type.display(19))
                                    Spacer()
                                    let done = progressStore.completedCount(for: workout)
                                    Text(done == workout.allExercises.count ? "DONE ✓" : "\(done) / \(workout.allExercises.count)")
                                        .font(S5Type.data(10))
                                        .foregroundStyle(S5Theme.red)
                                }
                                .padding(16)
                                .background(S5Theme.panel)
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button("Reset all progress", role: .destructive) {
                        showResetConfirmation = true
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                }
                .padding(18)
            }
            .background(S5Theme.black)
            .navigationTitle("Progress")
            .toolbarBackground(S5Theme.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .confirmationDialog("Reset all workout progress?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { progressStore.reset() }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
