import Combine
import Foundation

struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let prescription: String
    let cue: String
    let symbol: String
}

struct Workout: Identifiable, Hashable {
    let id: Int
    let focus: String
    let kicker: String
    let strength: [Exercise]
    let circuit: [Exercise]

    var allExercises: [Exercise] { strength + circuit }
}

final class ProgressStore: ObservableObject {
    @Published private(set) var completed: Set<String>
    private let storageKey = "steinberg-five-progress"

    init() {
        completed = Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? [])
    }

    func isComplete(_ exerciseID: String) -> Bool {
        completed.contains(exerciseID)
    }

    func toggle(_ exerciseID: String) {
        if completed.contains(exerciseID) {
            completed.remove(exerciseID)
        } else {
            completed.insert(exerciseID)
        }
        save()
    }

    func reset() {
        completed.removeAll()
        save()
    }

    func completedCount(for workout: Workout) -> Int {
        workout.allExercises.filter { completed.contains($0.id) }.count
    }

    func completion(for workout: Workout) -> Double {
        guard !workout.allExercises.isEmpty else { return 0 }
        return Double(completedCount(for: workout)) / Double(workout.allExercises.count)
    }

    private func save() {
        UserDefaults.standard.set(Array(completed), forKey: storageKey)
    }
}

enum WorkoutData {
    static let workouts: [Workout] = [
        Workout(
            id: 1, focus: "Chest", kicker: "Press with purpose",
            strength: [
                exercise("d1-s1", "Flat Barbell Bench Press", "4 × 6–8", "Shoulder blades back. Drive feet down.", "figure.strengthtraining.traditional"),
                exercise("d1-s2", "Incline Dumbbell Bench Press", "3 × 10", "Control the descent. Keep wrists stacked.", "dumbbell.fill"),
                exercise("d1-s3", "Seated Chest Press Machine", "3 × 12", "Chest tall. Stop just short of lockout.", "figure.strengthtraining.functional"),
                exercise("d1-s4", "Pec Deck or Dumbbell Fly", "3 × 12–15", "Soft elbows. Hug a wide barrel.", "figure.mind.and.body")
            ],
            circuit: circuit(1, [
                ("Dumbbell Bench Press", "Smooth reps; keep ribs down.", "dumbbell.fill"),
                ("Push-Ups", "Body stays in one strong line.", "figure.strengthtraining.functional"),
                ("Step-Ups", "Own the top; step down quietly.", "figure.stair.stepper"),
                ("Dumbbell Fly", "Light weight, long controlled arc.", "figure.mind.and.body"),
                ("Jumping Jacks", "Stay tall and land softly.", "figure.jumprope"),
                ("Reverse Lunges", "Step back far enough to stay stable.", "figure.step.training"),
                ("Bench Dips", "Keep shoulders down and back.", "figure.strengthtraining.functional"),
                ("Crunches", "Exhale and curl ribs toward hips.", "figure.core.training"),
                ("V Sit-Ups on Bench", "Brace first; move with control.", "figure.pilates")
            ])
        ),
        Workout(
            id: 2, focus: "Back", kicker: "Build a stronger frame",
            strength: [
                exercise("d2-s1", "Lat Pulldown", "4 × 10", "Lead with elbows. Pull toward upper chest.", "figure.strengthtraining.traditional"),
                exercise("d2-s2", "Barbell Bent-Over Row", "3 × 8–10", "Hinge, brace, then row to lower ribs.", "figure.rower"),
                exercise("d2-s3", "Seated Row Machine", "3 × 12", "Stay tall. Pause when handles reach ribs.", "figure.rower"),
                exercise("d2-s4", "Cable Pullover or Straight-Arm Lat Pull", "3 × 15", "Arms long. Sweep down with your lats.", "figure.strengthtraining.functional")
            ],
            circuit: circuit(2, [
                ("Bent-Over Dumbbell Row", "Square the hips; row toward your pocket.", "dumbbell.fill"),
                ("Dumbbell Shrugs", "Lift straight up; pause at the top.", "figure.strengthtraining.traditional"),
                ("Dumbbell Straight-Leg Deadlift", "Push hips back with a flat back.", "figure.strengthtraining.functional"),
                ("Jumping Jacks", "Stay light on your feet.", "figure.jumprope"),
                ("Crunches", "Exhale fully at the top.", "figure.core.training"),
                ("Walking Lunges", "Long, balanced steps.", "figure.walk"),
                ("Push-Ups", "Brace glutes and move as one piece.", "figure.strengthtraining.functional"),
                ("Step-Ups", "Drive through the whole lead foot.", "figure.stair.stepper"),
                ("Rear Delt Dumbbell Fly", "Reach wide; keep traps relaxed.", "figure.mind.and.body")
            ])
        ),
        Workout(
            id: 3, focus: "Legs", kicker: "Strong from the ground up",
            strength: [
                exercise("d3-s1", "Barbell Back Squat or Leg Press", "4 × 6–8", "Brace hard. Track knees over toes.", "figure.strengthtraining.traditional"),
                exercise("d3-s2", "Dumbbell Goblet Squat", "3 × 12", "Stay tall and sit between your hips.", "dumbbell.fill"),
                exercise("d3-s3", "Lying or Seated Leg Curl Machine", "3 × 15", "Keep hips planted. Squeeze, then lower slowly.", "figure.strengthtraining.functional")
            ],
            circuit: circuit(3, [
                ("Bodyweight Squats", "Use full comfortable depth.", "figure.strengthtraining.functional"),
                ("Walking Lunges", "Stay tall and step smoothly.", "figure.walk"),
                ("Step-Ups", "Plant the whole foot on the bench.", "figure.stair.stepper"),
                ("Reverse Lunges", "Drop the back knee straight down.", "figure.step.training"),
                ("Dumbbell Straight-Leg Deadlift", "Hinge through the hips.", "dumbbell.fill"),
                ("Jumping Jacks", "Land softly.", "figure.jumprope"),
                ("Crunches", "Move your ribs, not your neck.", "figure.core.training"),
                ("V Sit-Ups", "Keep the tempo controlled.", "figure.pilates"),
                ("Push-Ups", "Use a bench if form fades.", "figure.strengthtraining.functional")
            ])
        ),
        Workout(
            id: 4, focus: "Shoulders", kicker: "Own the overhead",
            strength: [
                exercise("d4-s1", "Seated Dumbbell Shoulder Press", "4 × 10", "Stack wrists over elbows. Keep ribs down.", "dumbbell.fill"),
                exercise("d4-s2", "Dumbbell Lateral Raise", "4 × 15", "Lead with elbows; stop around shoulder height.", "figure.mind.and.body"),
                exercise("d4-s3", "Dumbbell Front Raise", "3 × 12", "No swinging. Raise with control.", "figure.strengthtraining.functional"),
                exercise("d4-s4", "Cable Rear Delt Fly or Rear Delt Machine", "3 × 15", "Reach wide and keep shoulders relaxed.", "figure.strengthtraining.traditional")
            ],
            circuit: circuit(4, [
                ("Standing Dumbbell Shoulder Press", "Squeeze glutes; avoid leaning back.", "dumbbell.fill"),
                ("Dumbbell Lateral Raise", "Use a light, steady weight.", "figure.mind.and.body"),
                ("Rear Delt Dumbbell Fly", "Hinge and reach wide.", "figure.strengthtraining.functional"),
                ("Jumping Jacks", "Quick, quiet feet.", "figure.jumprope"),
                ("Crunches", "Exhale as you lift.", "figure.core.training"),
                ("Step-Ups", "Control the return.", "figure.stair.stepper"),
                ("Walking Lunges", "Keep the front knee stable.", "figure.walk"),
                ("Bench Dips", "Use a short pain-free range.", "figure.strengthtraining.functional"),
                ("Push-Ups", "Finish with clean reps.", "figure.strengthtraining.functional")
            ])
        ),
        Workout(
            id: 5, focus: "Arms", kicker: "Finish the week strong",
            strength: [
                exercise("d5-s1", "Barbell Curl", "4 × 10–12", "Pin elbows to your sides; no swinging.", "figure.strengthtraining.traditional"),
                exercise("d5-s2", "Dumbbell Hammer Curl", "3 × 12", "Neutral grip. Lower for a full count.", "dumbbell.fill"),
                exercise("d5-s3", "Rope Triceps Pushdown", "3 × 15", "Keep upper arms still; split the rope.", "figure.strengthtraining.functional"),
                exercise("d5-s4", "Dumbbell Overhead Triceps Extension", "3 × 12", "Point elbows forward and keep ribs down.", "figure.strengthtraining.traditional")
            ],
            circuit: circuit(5, [
                ("Dumbbell Curl to Press", "Curl cleanly, then press overhead.", "dumbbell.fill"),
                ("Dumbbell Shrugs", "Pause at the top.", "figure.strengthtraining.traditional"),
                ("Jumping Jacks", "Keep a steady rhythm.", "figure.jumprope"),
                ("Crunches", "Curl up on the exhale.", "figure.core.training"),
                ("V Sit-Ups on Bench", "Brace and balance.", "figure.pilates"),
                ("Bench Dips", "Shoulders stay away from ears.", "figure.strengthtraining.functional"),
                ("Walking Lunges", "Smooth, balanced steps.", "figure.walk"),
                ("Step-Ups", "Drive through the lead leg.", "figure.stair.stepper"),
                ("Push-Ups", "End on quality, not speed.", "figure.strengthtraining.functional")
            ])
        )
    ]

    private static func exercise(_ id: String, _ name: String, _ prescription: String, _ cue: String, _ symbol: String) -> Exercise {
        Exercise(id: id, name: name, prescription: prescription, cue: cue, symbol: symbol)
    }

    private static func circuit(_ day: Int, _ rows: [(String, String, String)]) -> [Exercise] {
        rows.enumerated().map { index, row in
            Exercise(id: "d\(day)-c\(index + 1)", name: row.0, prescription: "45 seconds", cue: row.1, symbol: row.2)
        }
    }
}
