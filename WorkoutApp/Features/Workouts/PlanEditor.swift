import SwiftUI

/// A custom studio editing a local draft. Cancel never changes a saved workout.
struct PlanEditor: View {
    @State var plan: WorkoutPlan
    var onSave: (WorkoutPlan) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var addingExercises = false
    @State private var detail: Exercise?
    private var tint: Color { WorkoutStyle.color(plan.color) }
    private var valid: Bool { !plan.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                StudioHeader(title: "Workout studio", subtitle: "Build something worth showing up for.", close: { dismiss() })
                preview
                StudioField(title: "Give it a name", placeholder: "e.g. Upper body power", text: $plan.name)
                VStack(alignment: .leading, spacing: 14) {
                    sectionLabel("01", "Make it yours")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(WorkoutStyle.icons, id: \.self) { icon in
                            Button { plan.icon = icon } label: {
                                Image(systemName: icon).font(.system(size: 21, weight: .bold))
                                    .frame(maxWidth: .infinity).frame(height: 48)
                                    .foregroundStyle((plan.icon ?? "dumbbell.fill") == icon ? tint : Palette.muted)
                                    .background((plan.icon ?? "dumbbell.fill") == icon ? tint.opacity(0.15) : Palette.surface, in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke((plan.icon ?? "dumbbell.fill") == icon ? tint : Palette.line, lineWidth: 1.5))
                            }.accessibilityLabel("\(icon.replacingOccurrences(of: ".fill", with: "").replacingOccurrences(of: ".", with: " ")) icon")
                                .accessibilityAddTraits((plan.icon ?? "dumbbell.fill") == icon ? .isSelected : [])
                        }
                    }
                    HStack(spacing: 14) {
                        Text("COLOR").font(.system(size: 10, weight: .heavy)).tracking(1).foregroundStyle(Palette.muted)
                        Spacer()
                        ForEach(WorkoutStyle.colors, id: \.self) { color in
                            Button { plan.color = color } label: {
                                Circle().fill(WorkoutStyle.color(color)).frame(width: 36, height: 36)
                                    .overlay { if (plan.color ?? "sky") == color { Image(systemName: "checkmark").font(.system(size: 14, weight: .heavy)).foregroundStyle(Palette.background) } }
                                    .frame(width: 44, height: 44)
                            }.accessibilityLabel("\(color) color").accessibilityAddTraits((plan.color ?? "sky") == color ? .isSelected : [])
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 14) {
                    sectionLabel("02", "Find your focus")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(ExerciseLibrary.groups, id: \.self) { group in
                            ChoiceChip(title: group, selected: plan.focus == group, tint: tint) { plan.focus = group }
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 16) {
                    sectionLabel("03", "Mix your moves · \(plan.exercises.count)")
                    if plan.exercises.isEmpty {
                        HStack(spacing: 14) {
                            Image(systemName: "square.stack.3d.up.fill").font(.title2).foregroundStyle(tint)
                            Text("Every great session starts with one move.").font(.subheadline).foregroundStyle(Palette.muted)
                        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                            .background(tint.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
                    }
                    ForEach($plan.exercises) { $item in
                        exerciseCard(item: $item)
                    }
                    Button { addingExercises = true } label: {
                        Label("Add from exercise library", systemImage: "plus.circle.fill")
                            .font(.system(size: 15, weight: .bold)).frame(maxWidth: .infinity).padding(20)
                            .foregroundStyle(tint)
                            .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(tint.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
                    }
                }
            }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(Palette.background)
            .safeAreaInset(edge: .bottom) {
                Button {
                    plan.name = plan.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(plan)
                    dismiss()
                } label: { Label("Save workout", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(PrimaryButtonStyle()).disabled(!valid).opacity(valid ? 1 : 0.45)
                    .padding(20).background(Palette.background)
            }
            .sheet(isPresented: $addingExercises) {
                ScrollView {
                    VStack(spacing: 24) {
                        StudioHeader(title: "Pick your moves", subtitle: "Tap + to add. Tap a move to learn more.", close: { addingExercises = false })
                        ExerciseBrowser(selectedIDs: Set(plan.exercises.map(\.exerciseID))) { exercise in
                            plan.exercises.append(PlannedExercise(exerciseID: exercise.id, amount: exercise.timed ? 30 : 10))
                        }
                    }.padding(24)
                }.background(Palette.background).fontDesign(.rounded)
            }
            .sheet(item: $detail) { ExerciseDetailView(exercise: $0) }
            .fontDesign(.rounded).foregroundStyle(Palette.ink).tint(tint)
            .sensoryFeedback(.selection, trigger: plan.icon)
            .sensoryFeedback(.selection, trigger: plan.color)
    }

    private var preview: some View {
        HStack(spacing: 20) {
            WorkoutBadge(symbol: plan.icon ?? "dumbbell.fill", tint: tint, size: 80).rotationEffect(.degrees(-7))
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NEXT FAVORITE").font(.system(size: 9, weight: .heavy)).tracking(1.8).foregroundStyle(tint)
                Text(plan.name.isEmpty ? "Untitled energy" : plan.name).font(.system(size: 23, weight: .heavy)).lineLimit(2)
                Text("\(plan.focus) · \(plan.exercises.count) \(plan.exercises.count == 1 ? "move" : "moves")").font(.caption.bold()).foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 0)
        }.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [tint.opacity(0.16), Palette.surface], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 28))
            .overlay(alignment: .topTrailing) { Image(systemName: "sparkle").foregroundStyle(tint.opacity(0.6)).padding(15) }
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(tint.opacity(0.25), lineWidth: 1.5))
    }

    private func sectionLabel(_ number: String, _ title: String) -> some View {
        HStack(spacing: 10) {
            Text(number).font(.system(size: 10, weight: .heavy)).foregroundStyle(tint)
                .frame(width: 28, height: 28).background(tint.opacity(0.12), in: Circle())
            Text(title).font(.system(size: 17, weight: .heavy))
        }
    }

    private func exerciseCard(item: Binding<PlannedExercise>) -> some View {
        let value = item.wrappedValue
        let index = plan.exercises.firstIndex { $0.id == value.id } ?? 0
        return VStack(spacing: 18) {
            HStack(spacing: 10) {
                Text(String(format: "%02d", index + 1)).font(.caption.bold()).foregroundStyle(tint)
                Button { detail = value.exercise } label: {
                    Text(value.exercise?.name ?? "Unavailable exercise").font(.headline).foregroundStyle(Palette.ink)
                    Image(systemName: "info.circle").font(.caption)
                }
                Spacer(minLength: 0)
                Button { plan.exercises.removeAll { $0.id == value.id } } label: { Image(systemName: "xmark").font(.caption.bold()).frame(width: 36, height: 44) }
                    .foregroundStyle(Palette.muted).accessibilityLabel("Remove \(value.exercise?.name ?? "exercise")")
            }
            HStack(spacing: 16) {
                NumberControl(title: "Sets", value: item.sets, range: 1...20)
                NumberControl(title: value.exercise?.timed == true ? "Seconds" : "Reps", value: item.amount, range: 1...300)
            }
            HStack {
                Text("MOVE ORDER").font(.system(size: 9, weight: .heavy)).tracking(1).foregroundStyle(Palette.muted)
                Spacer()
                Button { plan.exercises.swapAt(index, index - 1) } label: { Image(systemName: "arrow.up").frame(width: 44, height: 36) }
                    .disabled(index == 0).accessibilityLabel("Move exercise earlier")
                Button { plan.exercises.swapAt(index, index + 1) } label: { Image(systemName: "arrow.down").frame(width: 44, height: 36) }
                    .disabled(index == plan.exercises.count - 1).accessibilityLabel("Move exercise later")
            }
        }.padding(18).background(Palette.surface, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Palette.line, lineWidth: 1.5))
    }
}
