import SwiftUI

struct OnboardingView: View {
    @ObservedObject var store: AppStore
    var onDone: () -> Void = {}
    @State private var step = 0
    @State private var name = ""
    @State private var days: [TrainingDay] = []
    @State private var useTemplates = true
    private var editing: Bool { store.trainingSetup != nil }
    private var valid: Bool { step == 0 ? !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : !days.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    CadenceMark(size: 32)
                    Text("Cadence").font(.system(size: 22, weight: .heavy))
                    Spacer()
                    Text("\(step + 1) / 4").font(.caption.bold()).foregroundStyle(Palette.muted)
                    if editing { Button(action: onDone) { Image(systemName: "xmark").frame(width: 44, height: 44) }.accessibilityLabel("Cancel schedule changes") }
                }
                HStack(spacing: 6) {
                    ForEach(0..<4) { index in Capsule().fill(index <= step ? Palette.purple : Palette.line).frame(height: 5) }
                }
                switch step {
                case 0: welcome
                case 1: daySelection
                case 2: focusSelection
                default: review
                }
            }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
        }.background(Palette.background)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 14) {
                    if step > 0 {
                        Button { withAnimation { step -= 1 } } label: { Image(systemName: "arrow.left").font(.headline).frame(width: 48, height: 54).background(Palette.surface, in: RoundedRectangle(cornerRadius: 16)) }.accessibilityLabel("Previous step")
                    }
                    Button {
                        if step < 3 { withAnimation(.easeInOut(duration: 0.2)) { step += 1 } }
                        else { store.finishSetup(name: name, days: days.sorted { $0.weekday < $1.weekday }, addTemplates: useTemplates); onDone() }
                    } label: {
                        HStack { Text(step == 3 ? "Find my rhythm" : "Continue"); Spacer(); Image(systemName: "arrow.right") }
                    }.buttonStyle(PrimaryButtonStyle()).disabled(!valid).opacity(valid ? 1 : 0.45)
                }.padding(24).background(Palette.background)
            }
            .fontDesign(.rounded).foregroundStyle(Palette.ink).tint(Palette.purple)
            .sensoryFeedback(.selection, trigger: step)
            .onAppear {
                name = store.profile.displayName
                days = store.trainingSetup?.days ?? []
                useTemplates = !editing
            }
    }

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 26) {
            CadenceMark(size: 64).frame(maxWidth: .infinity).padding(.vertical, 8)
            Text("A routine that\nmoves like you.").font(.system(size: 32, weight: .heavy)).tracking(-1)
            Text("Build workouts like playlists. Swipe through your moves. Come back for the encore.").font(.body).foregroundStyle(Palette.muted)
            StudioField(title: "First things first", placeholder: "Your display name", text: $name)
            Text("Let’s put together a starting rhythm. You can change everything later.").font(.caption).foregroundStyle(Palette.muted)
        }
    }

    private var daySelection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Make room\nfor your rhythm.").font(.system(size: 34, weight: .heavy))
            Text("Which days do you want to work out? Pick a schedule that feels realistic.").foregroundStyle(Palette.muted)
            ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { weekday in
                let selected = days.contains { $0.weekday == weekday }
                Button {
                    if selected { days.removeAll { $0.weekday == weekday } }
                    else { days.append(TrainingDay(weekday: weekday, focus: "Full body")) }
                } label: {
                    HStack {
                        Text(TrainingDay.names[weekday - 1]).font(.headline)
                        Spacer()
                        Image(systemName: selected ? "checkmark.circle.fill" : "circle").font(.title2)
                    }.padding(18).foregroundStyle(selected ? Palette.purple : Palette.muted)
                        .background(selected ? Palette.purple.opacity(0.12) : Palette.surface, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected ? Palette.purple : Palette.line, lineWidth: 1.5))
                }.accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }

    private var focusSelection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Give each day\na direction.").font(.system(size: 34, weight: .heavy))
            Text("Choose a body focus for each workout day. We’ll match it to a starter playlist.").foregroundStyle(Palette.muted)
            ForEach($days) { $day in
                VStack(alignment: .leading, spacing: 14) {
                    Label(day.name, systemImage: "calendar").font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                        ForEach(ExerciseLibrary.groups, id: \.self) { focus in
                            ChoiceChip(title: focus, selected: day.focus == focus, tint: Palette.purple) { day.focus = focus }
                        }
                    }
                }.padding(20).background(Palette.surface, in: RoundedRectangle(cornerRadius: 24))
            }
        }
    }

    private var review: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your week.\nRemixed.").font(.system(size: 36, weight: .heavy))
            Text("\(days.count) workout days. Plenty of room to make it yours.").foregroundStyle(Palette.muted)
            ForEach(days.sorted { $0.weekday < $1.weekday }) { day in
                HStack(spacing: 14) {
                    WorkoutBadge(symbol: PlanTemplates.recommended(for: day.focus).icon, tint: WorkoutStyle.color(PlanTemplates.recommended(for: day.focus).color), size: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.name).font(.headline)
                        Text(day.focus).font(.caption).foregroundStyle(Palette.muted)
                    }
                    Spacer()
                }
            }
            Button { useTemplates.toggle() } label: {
                HStack(spacing: 14) {
                    Image(systemName: useTemplates ? "checkmark.circle.fill" : "circle").font(.title2)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add matching starter plans").font(.headline)
                        Text("Editable templates for your chosen focus areas. Turn this off to start empty.").font(.caption).foregroundStyle(Palette.muted)
                    }
                }.padding(20).foregroundStyle(Palette.purple).background(Palette.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
            }.accessibilityAddTraits(useTemplates ? .isSelected : [])
            Text("Your schedule is a guide, not a rule. Swap plans or take a rest day whenever you need.").font(.caption).foregroundStyle(Palette.muted)
        }
    }
}
