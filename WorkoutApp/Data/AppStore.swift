import Foundation
import Combine

/// Owns local persistence. Views edit plans through these methods rather than writing storage themselves.
final class AppStore: ObservableObject {
    @Published private(set) var plans: [WorkoutPlan]
    @Published private(set) var foods: [FoodEntry]
    @Published private(set) var completedDays: Set<String>
    @Published private(set) var profile: AccountProfile
    @Published private(set) var completions: [WorkoutCompletion]
    @Published private(set) var trainingSetup: TrainingSetup?
    @Published var selectedPlanID: UUID? { didSet { defaults.set(selectedPlanID?.uuidString, forKey: "cadence.selectedPlan") } }
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        trainingSetup = Self.read(TrainingSetup.self, key: "cadence.trainingSetup", defaults: defaults)
        selectedPlanID = defaults.string(forKey: "cadence.selectedPlan").flatMap(UUID.init(uuidString:))
        profile = Self.read(AccountProfile.self, key: "workout.profile", defaults: defaults) ?? AccountProfile()
        completions = Self.read([WorkoutCompletion].self, key: "workout.completions", defaults: defaults) ?? []
        plans = Self.read([WorkoutPlan].self, key: "workout.plans", defaults: defaults) ?? []
        foods = Self.read([FoodEntry].self, key: "workout.foodEntries", defaults: defaults) ?? []
        completedDays = Set((defaults.string(forKey: "workout.completedDays") ?? "").split(separator: ",").map(String.init))
    }

    func save(_ plan: WorkoutPlan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) { plans[index] = plan }
        else { plans.append(plan) }
        persist(plans, key: "workout.plans")
    }

    func deletePlan(_ id: UUID) {
        plans.removeAll { $0.id == id }
        persist(plans, key: "workout.plans")
    }

    func addFood(_ entry: FoodEntry) {
        foods.append(entry)
        persist(foods, key: "workout.foodEntries")
    }

    func deleteFood(_ id: UUID) {
        foods.removeAll { $0.id == id }
        persist(foods, key: "workout.foodEntries")
    }

    func saveProfile(_ profile: AccountProfile) {
        self.profile = profile
        persist(profile, key: "workout.profile")
    }

    func completeWorkout(_ plan: WorkoutPlan? = nil, sessionID: UUID? = nil) {
        if let sessionID, completions.contains(where: { $0.sessionID == sessionID }) { return }
        if let plan {
            completions.append(WorkoutCompletion(name: plan.name, icon: plan.icon ?? "dumbbell.fill", exerciseCount: plan.exercises.count, sessionID: sessionID))
            persist(completions, key: "workout.completions")
        }
        completedDays.insert(Self.dayKey(Date()))
        defaults.set(completedDays.sorted().joined(separator: ","), forKey: "workout.completedDays")
    }

    func finishSetup(name: String, days: [TrainingDay], addTemplates: Bool) {
        var updated = profile
        updated.displayName = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40))
        saveProfile(updated)
        trainingSetup = TrainingSetup(days: days)
        persist(trainingSetup, key: "cadence.trainingSetup")
        if addTemplates {
            for focus in ExerciseLibrary.groups where days.contains(where: { $0.focus == focus }) {
                let weekdays = days.filter { $0.focus == focus }.map(\.weekday)
                let plan = PlanTemplates.recommended(for: focus).makePlan(days: weekdays)
                save(plan)
                if selectedPlanID == nil { selectedPlanID = plan.id }
            }
        }
    }

    var todayDone: Bool { completedDays.contains(Self.dayKey(Date())) }
    var streak: Int {
        var date = Date()
        if !todayDone { date = Calendar.current.date(byAdding: .day, value: -1, to: date)! }
        var count = 0
        while completedDays.contains(Self.dayKey(date)) {
            count += 1
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }
        return count
    }

    static func dayKey(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year!)-\(parts.month!)-\(parts.day!)"
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func read<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
