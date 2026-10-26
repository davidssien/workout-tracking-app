import SwiftUI

/// Reused in Search and in a plan's exercise picker.
struct ExerciseBrowser: View {
    var selectedIDs: Set<String> = []
    var onSelect: (Exercise) -> Void
    @State private var query = ""
    @State private var group = "All"
    @State private var detail: Exercise?

    private var results: [Exercise] {
        ExerciseLibrary.all.filter {
            (group == "All" || $0.group == group) &&
            (query.isEmpty || "\($0.name) \($0.muscles) \($0.group)".localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(Palette.blue)
                TextField("Search exercises or muscles", text: $query).autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Clear search")
                }
            }.padding(16).background(Palette.surface, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line, lineWidth: 2))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["All"] + ExerciseLibrary.groups, id: \.self) { item in
                        ChoiceChip(title: item, selected: group == item) { group = item }
                    }
                }
            }
            Text("\(results.count) EXERCISES").font(.caption.bold()).tracking(1.5).foregroundStyle(Palette.muted)
            ForEach(results) { exercise in
                HStack(spacing: 12) {
                    Button { detail = exercise } label: {
                        HStack(spacing: 12) {
                            Image(systemName: exercise.symbol).font(.title2).frame(width: 46, height: 56)
                                .background(Palette.pale, in: RoundedRectangle(cornerRadius: 13))
                            VStack(alignment: .leading, spacing: 5) {
                                Text(exercise.name).font(.headline).foregroundStyle(Palette.ink)
                                Text(exercise.group).font(.caption).foregroundStyle(Palette.muted)
                            }
                            Spacer(minLength: 0)
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Button { onSelect(exercise) } label: {
                        Image(systemName: selectedIDs.contains(exercise.id) ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 28)).frame(width: 44, height: 44)
                    }.disabled(selectedIDs.contains(exercise.id))
                        .accessibilityLabel(selectedIDs.contains(exercise.id) ? "\(exercise.name) added" : "Add \(exercise.name)")
                }.padding(14).background(Palette.surface, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.line, lineWidth: 1.5))
            }
            if results.isEmpty { Text("No exercises found. Try another name or muscle group.").foregroundStyle(Palette.muted) }
        }
        .sheet(item: $detail) { ExerciseDetailView(exercise: $0) }
    }
}

struct LibraryView: View {
    @ObservedObject var store: AppStore
    @State private var addingExercise: Exercise?
    @State private var showingPlans = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Find your next favorite.").font(.system(size: 28, weight: .heavy))
            Text("Full playlists or individual moves. Make them yours.").foregroundStyle(Palette.muted)
            HStack(spacing: 10) {
                ChoiceChip(title: "Workout plans", symbol: "square.stack.fill", selected: showingPlans, tint: Palette.purple) { showingPlans = true }
                ChoiceChip(title: "Exercises", symbol: "dumbbell.fill", selected: !showingPlans) { showingPlans = false }
            }
            if showingPlans { PlanLibraryView(store: store) }
            else { ExerciseBrowser { addingExercise = $0 } }
        }.sheet(item: $addingExercise) { exercise in
            AddExerciseToPlan(store: store, exercise: exercise)
        }
    }
}

private struct AddExerciseToPlan: View {
    @ObservedObject var store: AppStore
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @State private var creating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                StudioHeader(title: "Find its home", subtitle: "Add \(exercise.name) to your rotation.", close: { dismiss() })
                ForEach(store.plans) { plan in
                    let contains = plan.exercises.contains { $0.exerciseID == exercise.id }
                    Button {
                        var updated = plan
                        updated.exercises.append(PlannedExercise(exerciseID: exercise.id, amount: exercise.timed ? 30 : 10))
                        store.save(updated)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            WorkoutBadge(symbol: plan.icon ?? "dumbbell.fill", tint: WorkoutStyle.color(plan.color), size: 50)
                            Text(plan.name).font(.headline).foregroundStyle(Palette.ink)
                            Spacer()
                            Image(systemName: contains ? "checkmark.circle.fill" : "plus.circle.fill")
                        }.padding(18)
                    }.buttonStyle(CardButtonStyle()).disabled(contains)
                }
                Button { creating = true } label: {
                    Label("Create a new workout", systemImage: "plus").frame(maxWidth: .infinity)
                }.buttonStyle(PrimaryButtonStyle())
            }.padding(24)
        }.background(Palette.background).fontDesign(.rounded)
            .sheet(isPresented: $creating) {
                PlanEditor(plan: WorkoutPlan(exercises: [PlannedExercise(exerciseID: exercise.id, amount: exercise.timed ? 30 : 10)])) {
                    store.save($0)
                    dismiss()
                }
            }
    }
}
