import SwiftUI

struct PlanDetailView: View {
    @ObservedObject var store: AppStore
    let planID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var editing = false
    @State private var deleting = false
    @State private var runningSession = false
    @State private var detail: Exercise?
    private var plan: WorkoutPlan? { store.plans.first { $0.id == planID } }

    var body: some View {
        ScrollView {
            if let plan {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        WorkoutBadge(symbol: plan.icon ?? "dumbbell.fill", tint: WorkoutStyle.color(plan.color), size: 80).rotationEffect(.degrees(-6))
                        Text(plan.name).font(.system(size: 30, weight: .heavy))
                        Text(plan.focus).font(.subheadline.bold()).padding(.horizontal, 14).padding(.vertical, 7).background(Palette.surface, in: Capsule())
                        Text("A playlist of \(plan.exercises.count) moves. Swipe through each set at your own pace.").font(.subheadline).foregroundStyle(Palette.muted)
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(24)
                        .background(WorkoutStyle.color(plan.color).opacity(0.12), in: RoundedRectangle(cornerRadius: 24))
                    ForEach(Array(plan.exercises.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 12) {
                            Text(String(format: "%02d", index + 1)).font(.caption.bold()).foregroundStyle(Palette.muted)
                            Button { detail = item.exercise } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.exercise?.name ?? "Unavailable exercise").font(.headline).foregroundStyle(Palette.ink)
                                    Text(item.summary).font(.subheadline).foregroundStyle(Palette.muted)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Button { editing = true } label: { Image(systemName: "slider.horizontal.3").frame(width: 44, height: 44).background(Palette.pale, in: RoundedRectangle(cornerRadius: 13)) }.accessibilityLabel("Edit exercise")
                        }.padding(16).background(Palette.surface, in: RoundedRectangle(cornerRadius: 20))
                    }
                    Button { editing = true } label: { Label("Remix this workout", systemImage: "slider.horizontal.3").frame(maxWidth: .infinity).padding(18) }.buttonStyle(CardButtonStyle())
                    if !plan.exercises.isEmpty {
                        Button { runningSession = true } label: { Label("Let’s find the rhythm", systemImage: "play.fill").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle())
                    } else { Text("Add your first exercise to get started.").foregroundStyle(Palette.muted) }
                    ShareLink(item: PlanSharing.export(plan)) {
                        Label("Share this playlist", systemImage: "square.and.arrow.up").font(.headline).frame(maxWidth: .infinity).padding(16)
                    }
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }
        }.background(Palette.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                HStack {
                    Button { dismiss() } label: { Label("My workouts", systemImage: "arrow.left").font(.subheadline.bold()).padding(12) }
                    Spacer()
                    Button { editing = true } label: { Image(systemName: "pencil").frame(width: 44, height: 44) }.accessibilityLabel("Edit workout")
                    Button { deleting = true } label: { Image(systemName: "trash").frame(width: 44, height: 44) }.accessibilityLabel("Delete workout")
                }.padding(.horizontal, 12).background(Palette.background)
            }
            .fullScreenCover(isPresented: $runningSession) { if let plan { WorkoutSessionView(store: store, plan: plan) } }
            .sheet(isPresented: $editing) { if let plan { PlanEditor(plan: plan) { store.save($0) } } }
            .sheet(item: $detail) { ExerciseDetailView(exercise: $0) }
            .sheet(isPresented: $deleting) {
                VStack(spacing: 24) {
                    StudioHeader(title: "Remove this workout?", close: { deleting = false })
                    WorkoutBadge(symbol: "trash.fill", tint: Palette.coral, size: 74)
                    Text("Your plan will be removed. Its exercises will stay in the library.").multilineTextAlignment(.center).foregroundStyle(Palette.muted)
                    Button { store.deletePlan(planID); deleting = false; dismiss() } label: { Text("Delete workout").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle())
                    Button("Keep my workout") { deleting = false }.font(.headline).padding(12)
                }.padding(24).frame(maxWidth: .infinity, maxHeight: .infinity).background(Palette.background).presentationDetents([.medium, .large])
            }
    }
}
