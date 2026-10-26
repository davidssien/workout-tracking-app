import SwiftUI

struct WorkoutSessionView: View {
    @ObservedObject var store: AppStore
    @State private var session: WorkoutSession
    @State private var translation: CGFloat = 0
    @State private var betweenRounds = false
    @State private var confirmingExit = false
    @State private var detail: Exercise?
    @State private var timerEnd: Date?
    @State private var remaining: Int = 0
    @State private var saved = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var tint: Color { WorkoutStyle.color(session.plan.color) }

    init(store: AppStore, plan: WorkoutPlan) {
        self.store = store
        _session = State(initialValue: WorkoutSession(plan: plan))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("NOW PLAYING").font(.system(size: 10, weight: .heavy)).tracking(2).foregroundStyle(tint)
                        Text(session.plan.name).font(.headline).lineLimit(2)
                    }
                    Spacer()
                    Button { if saved { dismiss() } else { confirmingExit = true } } label: {
                        Image(systemName: "xmark").font(.headline).frame(width: 44, height: 44).background(Palette.surface, in: Circle())
                    }.accessibilityLabel("End session")
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Palette.line)
                        Capsule().fill(tint).frame(width: geometry.size.width * session.progress)
                    }
                }.frame(height: 7).accessibilityLabel("\(Int(session.progress * 100)) percent complete")
                if session.isComplete { celebration }
                else if betweenRounds { roundTransition }
                else if let step = session.current {
                    HStack {
                        Text("SET \(step.round) OF \(session.totalRounds)").font(.caption.bold()).tracking(1)
                        Spacer()
                        Text("\(session.position + 1) / \(session.steps.count)").font(.caption.bold()).monospacedDigit()
                    }.foregroundStyle(Palette.muted)
                    movementCard(step)
                    queue
                    if step.item.exercise?.timed == true { timerControl(step) }
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right").font(.headline)
                        Text("Swipe right when you’re done").font(.subheadline.bold())
                    }.foregroundStyle(tint)
                    Button { completeMove() } label: {
                        Label("Complete move", systemImage: "checkmark").font(.subheadline.bold()).padding(12)
                    }.accessibilityHint("Alternative to swiping the exercise card")
                    if session.position > 0 {
                        Button { undo() } label: { Label("Undo last move", systemImage: "arrow.uturn.backward").font(.subheadline).padding(12) }.foregroundStyle(Palette.muted)
                    }
                } else {
                    Text("This plan has no available exercises.").foregroundStyle(Palette.muted)
                    Button("Back to workout") { dismiss() }.buttonStyle(PrimaryButtonStyle())
                }
            }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(Palette.background).foregroundStyle(Palette.ink).fontDesign(.rounded).tint(tint)
            .sensoryFeedback(.impact(weight: .medium), trigger: session.position)
            .sensoryFeedback(.success, trigger: saved)
            .interactiveDismissDisabled(!saved)
            .sheet(item: $detail) { ExerciseDetailView(exercise: $0) }
            .sheet(isPresented: $confirmingExit) {
                VStack(spacing: 24) {
                    StudioHeader(title: "Pause the rhythm?", close: { confirmingExit = false })
                    Text("Leaving now won’t count this as a completed workout.").foregroundStyle(Palette.muted)
                    Button { confirmingExit = false } label: { Text("Keep going").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle())
                    Button("End without saving") { confirmingExit = false; dismiss() }.font(.headline).foregroundStyle(Palette.coral).padding(16)
                }.padding(24).frame(maxWidth: .infinity, maxHeight: .infinity).background(Palette.background).presentationDetents([.medium])
            }
    }

    private func movementCard(_ step: WorkoutSession.Step) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32).fill(tint.opacity(0.12)).padding(.horizontal, 16).offset(y: 14)
            RoundedRectangle(cornerRadius: 32).fill(tint.opacity(0.18)).padding(.horizontal, 8).offset(y: 7)
            VStack(spacing: 16) {
                HStack {
                    Text("YOUR MOVE").font(.system(size: 10, weight: .heavy)).tracking(2).foregroundStyle(tint)
                    Spacer()
                    Button { detail = step.item.exercise } label: { Image(systemName: "info.circle").font(.title3).frame(width: 44, height: 32) }.accessibilityLabel("Exercise instructions")
                }
                HStack(spacing: 18) {
                    WorkoutBadge(symbol: step.item.exercise?.symbol ?? "dumbbell.fill", tint: tint, size: 64)
                    Text(step.item.exercise?.name ?? "Exercise").font(.system(size: 28, weight: .heavy)).frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(step.item.amount)").font(.system(size: 48, weight: .heavy)).monospacedDigit()
                    Text(step.item.exercise?.timed == true ? "seconds" : "reps").font(.headline).foregroundStyle(Palette.muted)
                }
                Text(step.item.exercise?.muscles ?? "").font(.caption.bold()).foregroundStyle(Palette.muted)
            }.padding(24).frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [tint.opacity(0.13), Palette.surface], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 32))
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: 32))
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(tint.opacity(0.28), lineWidth: 2))
                .overlay {
                    if translation > 35 {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 70, weight: .bold)).foregroundStyle(Palette.mint)
                            .padding(20).background(Palette.surface.opacity(0.94), in: Circle()).opacity(min(1, Double(translation / 110)))
                    }
                }
                .offset(x: translation).rotationEffect(.degrees(reduceMotion ? 0 : Double(translation / 30)))
                .gesture(DragGesture(minimumDistance: 20)
                    .onChanged { value in if abs(value.translation.width) > abs(value.translation.height) { translation = max(0, value.translation.width) } }
                    .onEnded { value in
                        if value.translation.width > 110 || (value.translation.width > 55 && value.predictedEndTranslation.width > 220) { completeMove() }
                        else { withAnimation(reduceMotion ? nil : .spring(response: 0.3)) { translation = 0 } }
                    })
                .accessibilityAction(named: "Complete move") { completeMove() }
        }.padding(.bottom, 14)
    }

    private var queue: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { Text("UP NEXT").font(.system(size: 10, weight: .heavy)).tracking(2); Spacer(); Text("This set").font(.caption) }.foregroundStyle(Palette.muted)
            if session.queue.isEmpty {
                Label(session.current?.round == session.totalRounds ? "One swipe from the finish." : "Next up: a fresh set.", systemImage: "sparkles").font(.subheadline.bold()).foregroundStyle(tint)
            }
            ForEach(session.queue.prefix(2)) { step in
                HStack(spacing: 14) {
                    WorkoutBadge(symbol: step.item.exercise?.symbol ?? "dumbbell.fill", tint: tint, size: 44)
                    Text(step.item.exercise?.name ?? "Exercise").font(.subheadline.bold())
                    Spacer()
                    Text("\(step.item.amount) \(step.item.exercise?.timed == true ? "sec" : "reps")").font(.caption).foregroundStyle(Palette.muted)
                }.padding(14).background(Palette.surface, in: RoundedRectangle(cornerRadius: 18))
            }
            if session.queue.count > 2 { Text("+ \(session.queue.count - 2) more in this set").font(.caption).foregroundStyle(Palette.muted) }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var roundTransition: some View {
        VStack(spacing: 24) {
            WorkoutBadge(symbol: "arrow.trianglehead.2.clockwise.rotate.90", tint: tint, size: 100)
            Text("That’s a set.").font(.system(size: 36, weight: .heavy))
            Text("Catch your breath. Your queue is ready for set \(session.current?.round ?? 1).")
                .multilineTextAlignment(.center).foregroundStyle(Palette.muted)
            Text("Only exercises with sets remaining come back around.").font(.caption).foregroundStyle(Palette.muted).multilineTextAlignment(.center)
            Button { withAnimation { betweenRounds = false }; resetTimer() } label: {
                Label("Start next set", systemImage: "play.fill").frame(maxWidth: .infinity)
            }.buttonStyle(PrimaryButtonStyle())
            Button { undo() } label: { Label("Undo last move", systemImage: "arrow.uturn.backward").padding(12) }
        }.padding(.vertical, 44)
    }

    private var celebration: some View {
        VStack(spacing: 24) {
            ZStack {
                ForEach(0..<8) { index in
                    Image(systemName: "sparkle").font(.system(size: index % 2 == 0 ? 18 : 12)).foregroundStyle([Palette.mint, Palette.purple, Palette.coral][index % 3])
                        .offset(x: cos(Double(index) * .pi / 4) * 90, y: sin(Double(index) * .pi / 4) * 80)
                }
                WorkoutBadge(symbol: "checkmark.seal.fill", tint: Palette.mint, size: 110)
            }.frame(height: 190)
            Text("Right on rhythm.").font(.system(size: 34, weight: .heavy))
            Text("\(session.steps.count) exercise sets.\nOne more promise kept to yourself.").multilineTextAlignment(.center).foregroundStyle(Palette.muted)
            Label("Workout saved · Streak updated", systemImage: "checkmark.circle.fill").font(.subheadline.bold()).foregroundStyle(Palette.mint)
            Button { dismiss() } label: { Text("Keep the good energy").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle())
        }
    }

    private func timerControl(_ step: WorkoutSession.Step) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let seconds = timerEnd.map { max(0, Int(ceil($0.timeIntervalSince(context.date)))) } ?? (remaining > 0 ? remaining : step.item.amount)
            Button {
                if let end = timerEnd { remaining = end > Date() ? max(1, Int(ceil(end.timeIntervalSinceNow))) : 0; timerEnd = nil }
                else { timerEnd = Date().addingTimeInterval(TimeInterval(remaining > 0 ? remaining : step.item.amount)) }
            } label: {
                Label(timerEnd != nil && seconds == 0 ? "Time’s up · swipe when ready" : "\(timerEnd == nil ? "Start" : "Pause") timer · \(seconds)s", systemImage: timerEnd == nil ? "play.fill" : "pause.fill")
                    .font(.subheadline.bold()).padding(16).frame(maxWidth: .infinity).background(tint.opacity(0.12), in: Capsule())
            }
        }
    }

    private func completeMove() {
        guard session.current != nil, !betweenRounds, !saved else { return }
        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
            betweenRounds = session.advance()
            translation = 0
        }
        resetTimer()
        if session.isComplete {
            store.completeWorkout(session.plan, sessionID: session.id)
            saved = true
        }
    }
    private func resetTimer() { timerEnd = nil; remaining = 0 }
    private func undo() { session.undo(); betweenRounds = false; translation = 0; resetTimer() }
}
