import Foundation

struct FoodEntry: Codable, Identifiable {
    var id = UUID()
    var name: String
    var calories: Int
    var date = Date()
}

