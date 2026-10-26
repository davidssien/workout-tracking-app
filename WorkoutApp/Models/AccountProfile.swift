import Foundation

struct AccountProfile: Codable {
    var displayName = ""
    var username = ""
    var bio = ""
    var avatar = "person.fill"
    var appearance = "system"
    var joined = Date()
}

struct WorkoutCompletion: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var exerciseCount: Int
    var date = Date()
    var sessionID: UUID? = nil
}
