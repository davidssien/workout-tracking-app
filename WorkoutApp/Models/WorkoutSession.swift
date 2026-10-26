import Foundation

/// Deterministic session engine, separate from animation. Each round contains only unfinished sets.
struct WorkoutSession {
    struct Step: Identifiable {
        let item: PlannedExercise
        let round: Int
        var id: String { "\(item.id)-\(round)" }
    }
    let id = UUID()
    let plan: WorkoutPlan
    let steps: [Step]
    private(set) var position = 0

    init(plan: WorkoutPlan) {
        self.plan = plan
        let items = plan.exercises.filter { $0.exercise != nil && $0.sets > 0 && $0.amount > 0 }
        let rounds = min(items.map(\.sets).max() ?? 0, 20)
        steps = rounds == 0 ? [] : (1...rounds).flatMap { round in
            items.filter { $0.sets >= round }.map { Step(item: $0, round: round) }
        }
    }
    var current: Step? { position < steps.count ? steps[position] : nil }
    var isComplete: Bool { !steps.isEmpty && position == steps.count }
    var totalRounds: Int { steps.last?.round ?? 0 }
    var progress: Double { steps.isEmpty ? 0 : Double(position) / Double(steps.count) }
    var queue: [Step] { guard let current else { return [] }; return Array(steps.dropFirst(position + 1).prefix { $0.round == current.round }) }
    /// Returns true when the next movement begins a new round.
    mutating func advance() -> Bool {
        guard let before = current else { return false }
        position += 1
        return current.map { $0.round != before.round } ?? false
    }
    mutating func undo() { position = max(0, position - 1) }
}
