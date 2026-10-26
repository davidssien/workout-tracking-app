import Foundation

/// One movement in the library. Stable IDs keep saved plans linked to their exercises.
struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let group: String
    let muscles: String
    let difficulty: Int
    let symbol: String
    let instructions: String
    var timed = false
}
