import Foundation

struct TrainingDay: Codable, Identifiable, Equatable {
    var weekday: Int
    var focus: String
    var id: Int { weekday }
    var name: String { Self.names[weekday - 1] }
    static let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
}

struct TrainingSetup: Codable {
    var days: [TrainingDay]
    var completedAt = Date()
}
