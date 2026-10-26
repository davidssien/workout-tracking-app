import SwiftUI

struct PlanLibraryView: View {
    @ObservedObject var store: AppStore
    @State private var query = ""
    @State private var focus = "All"
    @State private var selected: String?
    @State private var importing = false
    private var results: [PlanTemplate] {
        PlanTemplates.all.filter {
            (focus == "All" || $0.focus == focus) && (query.isEmpty || "\($0.name) \($0.focus) \($0.subtitle) \($0.exerciseIDs.compactMap { id in ExerciseLibrary.all.first { $0.id == id }?.name }.joined(separator: " "))".localizedCaseInsensitiveContains(query))
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StudioField(title: "Find your next rotation", placeholder: "Search plans, focus, or moves", text: $query)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack { ForEach(["All"] + ExerciseLibrary.groups, id: \.self) { group in ChoiceChip(title: group, selected: focus == group, tint: Palette.purple) { focus = group } } }
            }
            Button { importing = true } label: {
                HStack(spacing: 14) {
                    Image(systemName: "square.and.arrow.down").font(.title2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("A playlist from a friend?").font(.headline)
                        Text("Import a shared Cadence plan").font(.caption).foregroundStyle(Palette.muted)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                }.padding(18)
            }.buttonStyle(CardButtonStyle())
            Text("CADENCE STARTER PLANS").font(.system(size: 10, weight: .heavy)).tracking(1.5).foregroundStyle(Palette.muted)
            ForEach(results) { template in
                Button { selected = template.id } label: {
                    HStack(spacing: 16) {
                        WorkoutBadge(symbol: template.icon, tint: WorkoutStyle.color(template.color), size: 66).rotationEffect(.degrees(-5))
                        VStack(alignment: .leading, spacing: 7) {
                            Text(template.name).font(.headline).foregroundStyle(Palette.ink)
                            Text("\(template.focus) · \(template.exerciseIDs.count) moves").font(.caption.bold()).foregroundStyle(Palette.muted)
                            Text(template.subtitle).font(.caption).foregroundStyle(Palette.muted)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "plus.circle.fill").foregroundStyle(WorkoutStyle.color(template.color))
                    }.padding(18)
                }.buttonStyle(CardButtonStyle())
            }
            if results.isEmpty { Text("No plans found. Try a body area or exercise name.").foregroundStyle(Palette.muted) }
        }
        .sheet(isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } })) {
            if let template = PlanTemplates.all.first(where: { $0.id == selected }) {
                PlanEditor(plan: template.makePlan()) { plan in store.save(plan); store.selectedPlanID = plan.id }
            }
        }
        .sheet(isPresented: $importing) { ImportPlanView { plan in store.save(plan); store.selectedPlanID = plan.id } }
    }
}
