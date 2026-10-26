import Foundation

/// Portable, versioned plan payloads. No profile information or workout history is included.
enum PlanSharing {
    private struct Envelope: Codable { var version: Int; var plan: WorkoutPlan }
    enum ImportError: LocalizedError {
        case invalid, version, exercise
        var errorDescription: String? {
            switch self {
            case .invalid: "This doesn’t look like a valid Cadence plan. Copy the complete shared text and try again."
            case .version: "This plan uses a newer sharing format. Update Cadence before importing it."
            case .exercise: "This plan includes an exercise that isn’t available in this version of Cadence."
            }
        }
    }
    static func export(_ plan: WorkoutPlan) -> String {
        var portablePlan = plan
        portablePlan.scheduledDays = []
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(Envelope(version: 1, plan: portablePlan)), let json = String(data: data, encoding: .utf8) else { return "" }
        return "Try my Cadence workout: \(plan.name)\nImport this in Cadence → Search → Plans → Import.\n\n" + json
    }
    static func decode(_ text: String) throws -> WorkoutPlan {
        guard text.utf8.count < 100_000, let start = text.firstIndex(of: "{"), let data = String(text[start...]).data(using: .utf8),
              let envelope = try? JSONDecoder().decode(Envelope.self, from: data) else { throw ImportError.invalid }
        guard envelope.version == 1 else { throw ImportError.version }
        var plan = envelope.plan
        plan.name = plan.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !plan.name.isEmpty, plan.name.count <= 80, plan.exercises.count <= 60,
              ExerciseLibrary.groups.contains(plan.focus),
              plan.exercises.allSatisfy({ (1...20).contains($0.sets) && (1...300).contains($0.amount) }) else { throw ImportError.invalid }
        guard plan.exercises.allSatisfy({ $0.exercise != nil }) else { throw ImportError.exercise }
        plan.id = UUID()
        plan.exercises = plan.exercises.map { item in var copy = item; copy.id = UUID(); return copy }
        // Imported schedules never replace the recipient's own schedule.
        plan.scheduledDays = []
        return plan
    }
}
