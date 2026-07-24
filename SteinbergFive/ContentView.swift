import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var selectedDay = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            PlanView(selectedDay: $selectedDay, selectedTab: $selectedTab)
                .tabItem { Label("Plan", systemImage: "calendar") }
                .tag(0)

            WorkoutView(selectedDay: $selectedDay)
                .tabItem { Label("Workout", systemImage: "figure.strengthtraining.traditional") }
                .tag(1)

            S5ProgressView(selectedDay: $selectedDay, selectedTab: $selectedTab)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(2)
        }
        .tint(S5Theme.red)
    }
}

struct WorkoutView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Binding var selectedDay: Int
    @State private var showTimer = false

    private var workout: Workout { WorkoutData.workouts[selectedDay - 1] }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    HeroView()
                    DayPicker(selectedDay: $selectedDay)

                    VStack(spacing: 28) {
                        WorkoutTitle(workout: workout)
                        ExerciseSection(number: "01", title: "Strength block", subtitle: "40–45 min · Rest 60–90 sec", exercises: workout.strength)
                        CircuitSection(exercises: workout.circuit, showTimer: $showTimer)
                        SafetyNote()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 26)
                    .padding(.bottom, 32)
                }
            }
            .background(S5Theme.black)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { S5Wordmark() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showTimer = true } label: {
                        Label("Timer", systemImage: "timer")
                            .font(S5Type.data(11))
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
            }
            .toolbarBackground(S5Theme.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showTimer) { IntervalTimerView() }
        }
    }
}

private struct HeroView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HeroImage")
                .resizable()
                .scaledToFill()
                .frame(height: 280)
                .clipped()

            LinearGradient(
                colors: [S5Theme.black.opacity(0.05), S5Theme.black.opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(text: "Your 5-day hybrid plan")
                Text("SHOW UP.\nPUT IN WORK.")
                    .font(S5Type.display(54))
                    .tracking(-0.8)
                    .lineSpacing(-5)
                HStack(spacing: 12) {
                    Stat(value: "40–45", label: "MIN LIFT")
                    Circle().fill(S5Theme.red).frame(width: 4, height: 4)
                    Stat(value: "30", label: "MIN CIRCUIT")
                    Circle().fill(S5Theme.red).frame(width: 4, height: 4)
                    Stat(value: "5", label: "DAYS")
                }
            }
            .padding(20)
        }
        .frame(height: 280)
    }

    private struct Stat: View {
        let value: String
        let label: String
        var body: some View {
            HStack(spacing: 3) {
                Text(value).fontWeight(.black).foregroundStyle(.white)
                Text(label).foregroundStyle(.white.opacity(0.56))
            }
            .font(S5Type.data(9, weight: .regular))
        }
    }
}

private struct DayPicker: View {
    @Binding var selectedDay: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 1) {
                ForEach(WorkoutData.workouts) { workout in
                    Button {
                        withAnimation(.snappy) { selectedDay = workout.id }
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("DAY").font(S5Type.data(8))
                            Text("0\(workout.id)").font(S5Type.display(28))
                            Text(workout.focus.uppercased()).font(S5Type.data(9))
                        }
                        .frame(width: 88, alignment: .leading)
                        .padding(.vertical, 13)
                        .padding(.leading, 14)
                        .foregroundStyle(selectedDay == workout.id ? .white : .white.opacity(0.42))
                        .background(selectedDay == workout.id ? S5Theme.red : S5Theme.panel)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(S5Theme.panel)
    }
}

private struct WorkoutTitle: View {
    @EnvironmentObject private var progressStore: ProgressStore
    let workout: Workout

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                SectionLabel(text: "Day 0\(workout.id) / 05")
                Text(workout.focus.uppercased())
                    .font(S5Type.display(60))
                    .tracking(-0.8)
                Text(workout.kicker)
                    .font(.subheadline)
                    .foregroundStyle(S5Theme.secondary)
            }
            Spacer()
            S5ProgressRing(progress: progressStore.completion(for: workout))
        }
    }
}

private struct ExerciseSection: View {
    let number: String
    let title: String
    let subtitle: String
    let exercises: [Exercise]

    var body: some View {
        VStack(spacing: 14) {
            BlockHeader(number: number, title: title, subtitle: subtitle)
            VStack(spacing: 8) {
                ForEach(exercises) { exercise in ExerciseRow(exercise: exercise) }
            }
        }
    }
}

private struct CircuitSection: View {
    let exercises: [Exercise]
    @Binding var showTimer: Bool

    var body: some View {
        VStack(spacing: 14) {
            BlockHeader(number: "02", title: "Conditioning circuit", subtitle: "3 rounds · 45 sec each · 2 min rest")
            HStack(alignment: .top, spacing: 8) {
                Text("AMRAP").fontWeight(.black).foregroundStyle(S5Theme.red)
                Text("Move continuously with clean form. Scale the pace before the movement.")
                    .foregroundStyle(S5Theme.secondary)
            }
            .font(S5Type.data(11, weight: .regular))
            .padding(13)
            .background(S5Theme.red.opacity(0.1))
            .overlay(Rectangle().stroke(S5Theme.red.opacity(0.4)))

            VStack(spacing: 8) {
                ForEach(exercises) { exercise in ExerciseRow(exercise: exercise) }
            }

            Button { showTimer = true } label: {
                HStack {
                    Text("START 45 SEC TIMER")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(S5Type.data(12, weight: .black))
                .padding(.horizontal, 18)
                .frame(height: 56)
                .background(S5Theme.red)
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(S5Theme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct BlockHeader: View {
    let number: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(S5Type.data(12, weight: .black))
                .frame(width: 40, height: 40)
                .background(S5Theme.red)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased()).font(S5Type.display(23))
                Text(subtitle.uppercased())
                    .font(S5Type.data(9, weight: .medium))
                    .foregroundStyle(S5Theme.secondary)
            }
            Spacer()
        }
    }
}

private struct ExerciseRow: View {
    @EnvironmentObject private var progressStore: ProgressStore
    let exercise: Exercise
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    withAnimation(.snappy) { isExpanded.toggle() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: exercise.symbol)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(S5Theme.red)
                            .frame(width: 44, height: 44)
                            .background(S5Theme.raised)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(S5Type.sans(14, weight: .bold))
                                .strikethrough(progressStore.isComplete(exercise.id))
                                .multilineTextAlignment(.leading)
                            Text(exercise.prescription.uppercased())
                                .font(S5Type.data(10))
                                .foregroundStyle(S5Theme.red)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "minus" : "plus")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(S5Theme.secondary)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.snappy) { progressStore.toggle(exercise.id) }
                } label: {
                    Image(systemName: progressStore.isComplete(exercise.id) ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 30))
                        .foregroundStyle(progressStore.isComplete(exercise.id) ? S5Theme.red : .white.opacity(0.25))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(progressStore.isComplete(exercise.id) ? "Mark incomplete" : "Mark complete")
            }
            .padding(12)

            if isExpanded {
                VStack(alignment: .leading, spacing: 5) {
                    SectionLabel(text: "Form cue")
                    Text(exercise.cue)
                        .font(.footnote)
                        .foregroundStyle(S5Theme.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 68)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(S5Theme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(progressStore.isComplete(exercise.id) ? 0.58 : 1)
    }
}

private struct SafetyNote: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle")
            Text("Train smart. Choose loads you can control. Stop for sharp pain, dizziness, or unusual shortness of breath.")
                .font(.footnote)
                .foregroundStyle(S5Theme.secondary)
        }
    }
}
