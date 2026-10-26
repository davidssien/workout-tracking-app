import SwiftUI

struct WorkoutsView: View {
    @ObservedObject var store: AppStore
    var onCreate: () -> Void
    private var activePlan: WorkoutPlan? {
        store.plans.first { $0.id == store.selectedPlanID }
        ?? store.plans.first { ($0.scheduledDays ?? []).contains(Calendar.current.component(.weekday, from: Date())) }
        ?? store.plans.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("LET’S MAKE MOVES").font(.system(size: 10, weight: .heavy)).tracking(2).foregroundStyle(Palette.purple)
                    Text(store.profile.displayName.isEmpty ? "Find your rhythm." : "Let’s go, \(store.profile.displayName).")
                        .font(.system(size: 29, weight: .heavy))
                }
                Spacer(minLength: 0)
                Image(systemName: "sparkles").font(.system(size: 28, weight: .bold)).foregroundStyle(Palette.purple).rotationEffect(.degrees(12))
            }
            StreakCard(store: store)
            if let days = store.trainingSetup?.days, !days.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { weekday in
                            let day = days.first { $0.weekday == weekday }
                            VStack(spacing: 8) {
                                Text(String(TrainingDay.names[weekday - 1].prefix(3))).font(.system(size: 10, weight: .bold))
                                Image(systemName: day == nil ? "moon.zzz.fill" : "dumbbell.fill").font(.system(size: 14, weight: .bold))
                            }.foregroundStyle(day == nil ? Palette.muted : Palette.purple).frame(width: 40, height: 58)
                                .background(day == nil ? Palette.surface : Palette.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Calendar.current.component(.weekday, from: Date()) == weekday ? Palette.purple : .clear, lineWidth: 1.5))
                                .accessibilityLabel("\(TrainingDay.names[weekday - 1]): \(day?.focus ?? "Rest day")")
                        }
                    }
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your rotation").font(.system(size: 23, weight: .heavy))
                    Text("Good energy, made by you.").font(.subheadline).foregroundStyle(Palette.muted)
                }
                Spacer()
                Button(action: onCreate) {
                    Image(systemName: "plus").font(.system(size: 19, weight: .heavy)).frame(width: 46, height: 46)
                        .foregroundStyle(Palette.purple).background(Palette.purple.opacity(0.13), in: RoundedRectangle(cornerRadius: 16))
                }.accessibilityLabel("Create workout")
            }
            if store.plans.isEmpty {
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        WorkoutBadge(symbol: "bolt.fill", tint: Palette.coral, size: 56).rotationEffect(.degrees(-12)).offset(y: 6)
                        WorkoutBadge(symbol: "dumbbell.fill", tint: Palette.purple, size: 76).rotationEffect(.degrees(5))
                        WorkoutBadge(symbol: "heart.fill", tint: Palette.mint, size: 56).rotationEffect(.degrees(12)).offset(y: 6)
                    }.padding(.top, 8).accessibilityHidden(true)
                    Text("Your kind of strong.").font(.system(size: 23, weight: .heavy))
                    Text("Pick your moves. Mix your perfect session.\nThis is where it all starts.")
                        .font(.subheadline).multilineTextAlignment(.center).foregroundStyle(Palette.muted)
                    Button(action: onCreate) {
                        Label("Build my first workout", systemImage: "plus.circle.fill").frame(maxWidth: .infinity)
                    }.buttonStyle(PrimaryButtonStyle())
                }.frame(maxWidth: .infinity).padding(24)
                    .background(LinearGradient(colors: [Palette.purple.opacity(0.08), Palette.surface], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 28))
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(Palette.purple.opacity(0.18), lineWidth: 1.5))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(store.plans) { plan in
                            ChoiceChip(title: plan.name, symbol: plan.icon ?? "dumbbell.fill", selected: activePlan?.id == plan.id, tint: WorkoutStyle.color(plan.color)) {
                                store.selectedPlanID = plan.id
                            }
                        }
                    }
                }
                if let plan = activePlan {
                    let tint = WorkoutStyle.color(plan.color)
                    NavigationLink { PlanDetailView(store: store, planID: plan.id) } label: {
                        HStack(spacing: 18) {
                            WorkoutBadge(symbol: plan.icon ?? "dumbbell.fill", tint: tint, size: 70)
                                .rotationEffect(.degrees(-6))
                            VStack(alignment: .leading, spacing: 8) {
                                Text(plan.focus.uppercased()).font(.system(size: 9, weight: .heavy)).tracking(1.5).foregroundStyle(tint)
                                Text(plan.name).font(.system(size: 21, weight: .heavy)).foregroundStyle(Palette.ink)
                                Text("\(plan.exercises.count) \(plan.exercises.count == 1 ? "move" : "moves") · Your pace").font(.caption.bold()).foregroundStyle(Palette.muted)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "arrow.up.right").font(.system(size: 15, weight: .heavy)).foregroundStyle(tint)
                        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                            .background(LinearGradient(colors: [tint.opacity(0.12), Palette.surface], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 25))
                    }.buttonStyle(CardButtonStyle())
                }
                Button(action: onCreate) {
                    Label("Mix a new workout", systemImage: "plus.circle.fill").frame(maxWidth: .infinity)
                }.buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}
