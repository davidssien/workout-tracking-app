import Foundation

struct WorkoutPlan: Identifiable, Codable {
    var id = UUID()
    var name = ""
    var focus = "Full body"
    var exercises: [PlannedExercise] = []
    // Optional fields preserve decoding of plans saved before customization existed.
    var icon: String? = nil
    var color: String? = nil
    var scheduledDays: [Int]? = nil
}

/// Settings belong to the plan, so the same exercise can have different sets in different plans.
struct PlannedExercise: Identifiable, Codable {
    var id = UUID()
    var exerciseID: String
    var sets = 3
    var amount = 10
    var exercise: Exercise? { ExerciseLibrary.all.first { $0.id == exerciseID } }
    var summary: String { "\(sets) × \(amount) \(exercise?.timed == true ? "sec" : "reps")" }
}
