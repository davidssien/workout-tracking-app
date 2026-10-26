import Foundation

struct PlanTemplate: Identifiable {
    let id: String
    let name: String
    let focus: String
    let subtitle: String
    let icon: String
    let color: String
    let exerciseIDs: [String]

    func makePlan(days: [Int] = []) -> WorkoutPlan {
        WorkoutPlan(name: name, focus: focus, exercises: exerciseIDs.map { id in
            PlannedExercise(exerciseID: id, sets: 3, amount: ExerciseLibrary.all.first { $0.id == id }?.timed == true ? 30 : 10)
        }, icon: icon, color: color, scheduledDays: days)
    }
}

enum PlanTemplates {
    static let all = [
        PlanTemplate(id: "full-foundation", name: "Everyday momentum", focus: "Full body", subtitle: "A balanced starting point. No equipment needed.", icon: "bolt.fill", color: "sky", exerciseIDs: ["squat", "wall-pushup", "bird-dog", "march"]),
        PlanTemplate(id: "upper-foundation", name: "Upper body rhythm", focus: "Upper body", subtitle: "Build your own push-day playlist.", icon: "dumbbell.fill", color: "violet", exerciseIDs: ["wall-pushup", "pushup", "plank"]),
        PlanTemplate(id: "lower-foundation", name: "Grounded & strong", focus: "Lower body", subtitle: "A lower-body session with a steady beat.", icon: "mountain.2.fill", color: "mint", exerciseIDs: ["squat", "lunge", "bridge", "calf"]),
        PlanTemplate(id: "core-foundation", name: "Center of gravity", focus: "Core", subtitle: "Small movements. A strong foundation.", icon: "figure.core.training", color: "coral", exerciseIDs: ["deadbug", "bird-dog", "plank"]),
        PlanTemplate(id: "gentle-full", name: "Ease into it", focus: "Full body", subtitle: "A gentler mix for finding your rhythm.", icon: "sun.max.fill", color: "mint", exerciseIDs: ["march", "wall-pushup", "calf", "bird-dog"]),
        PlanTemplate(id: "core-challenge", name: "Core encore", focus: "Core", subtitle: "A focused mix with a side-plank challenge.", icon: "flame.fill", color: "violet", exerciseIDs: ["deadbug", "plank", "side-plank"])
    ]
    static func recommended(for focus: String) -> PlanTemplate { all.first { $0.focus == focus } ?? all[0] }
}
