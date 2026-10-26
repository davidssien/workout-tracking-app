import SwiftUI

struct AccountView: View {
    @ObservedObject var store: AppStore
    @State private var editing = false
    @State private var editingSchedule = false
    private var name: String { store.profile.displayName.isEmpty ? "Your next chapter" : store.profile.displayName }

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            StudioHeader(title: "Your corner", subtitle: "A little progress. A lot to be proud of.")
            VStack(spacing: 16) {
                WorkoutBadge(symbol: store.profile.avatar, tint: Palette.purple, size: 88).rotationEffect(.degrees(-5))
                VStack(spacing: 6) {
                    Text(name).font(.system(size: 25, weight: .heavy))
                    Text(store.profile.username.isEmpty ? "Make this space yours" : "@\(store.profile.username)")
                        .font(.subheadline.bold()).foregroundStyle(Palette.purple)
                }
                if !store.profile.bio.isEmpty { Text(store.profile.bio).font(.subheadline).multilineTextAlignment(.center).foregroundStyle(Palette.muted) }
                Button { editing = true } label: { Label("Edit profile", systemImage: "pencil").font(.subheadline.bold()).padding(.horizontal, 22).padding(.vertical, 12) }
                    .foregroundStyle(Palette.purple).background(Palette.purple.opacity(0.12), in: Capsule())
            }.padding(26).frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Palette.purple.opacity(0.13), Palette.surface], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 28))
                .overlay(alignment: .topTrailing) { Image(systemName: "sparkles").foregroundStyle(Palette.purple).padding(22) }
            HStack(spacing: 10) {
                stat("Finished", value: store.completions.count, symbol: "checkmark.seal.fill", color: Palette.mint)
                stat("Day streak", value: store.streak, symbol: "flame.fill", color: Palette.coral)
                stat("Plans", value: store.plans.count, symbol: "square.stack.fill", color: Palette.purple)
            }
            VStack(alignment: .leading, spacing: 16) {
                Label("Set the mood", systemImage: "circle.lefthalf.filled").font(.headline)
                HStack(spacing: 8) {
                    ForEach(["system", "light", "dark"], id: \.self) { mode in
                        Button {
                            var profile = store.profile
                            profile.appearance = mode
                            store.saveProfile(profile)
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: mode == "dark" ? "moon.fill" : mode == "light" ? "sun.max.fill" : "circle.lefthalf.filled").font(.title3)
                                Text(mode.capitalized).font(.system(size: 12, weight: .bold))
                            }.frame(maxWidth: .infinity).padding(.vertical, 14)
                                .foregroundStyle(store.profile.appearance == mode ? Palette.purple : Palette.muted)
                                .background(store.profile.appearance == mode ? Palette.purple.opacity(0.13) : Palette.background, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(store.profile.appearance == mode ? Palette.purple : .clear, lineWidth: 1.5))
                        }.accessibilityAddTraits(store.profile.appearance == mode ? .isSelected : [])
                    }
                }
            }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(Palette.surface, in: RoundedRectangle(cornerRadius: 24))
            VStack(alignment: .leading, spacing: 16) {
                Text("Your victory lap").font(.title3.bold())
                if store.completions.isEmpty {
                    Text("Finish a workout to start your history. Every session counts.").foregroundStyle(Palette.muted).font(.subheadline)
                }
                ForEach(store.completions.sorted { $0.date > $1.date }.prefix(10)) { completion in
                    HStack(spacing: 14) {
                        WorkoutBadge(symbol: completion.icon, tint: Palette.mint, size: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.name).font(.subheadline.bold())
                            Text("\(completion.exerciseCount) \(completion.exerciseCount == 1 ? "move" : "moves") · \(completion.date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(Palette.muted)
                        }
                        Spacer()
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(Palette.mint)
                    }
                }
            }
            Button { editingSchedule = true } label: {
                HStack(spacing: 14) {
                    WorkoutBadge(symbol: "calendar", tint: Palette.blue, size: 48)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your weekly rhythm").font(.headline)
                        Text("\(store.trainingSetup?.days.count ?? 0) workout days · Edit schedule").font(.caption).foregroundStyle(Palette.muted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }.padding(18)
            }.buttonStyle(CardButtonStyle())
            Text("Profile and activity are saved on this device. No public account or social sharing is connected.")
                .font(.caption).foregroundStyle(Palette.muted)
        }.sheet(isPresented: $editing) { ProfileEditor(profile: store.profile) { store.saveProfile($0) } }
            .sheet(isPresented: $editingSchedule) { OnboardingView(store: store) { editingSchedule = false } }
    }

    private func stat(_ title: String, value: Int, symbol: String, color: Color) -> some View {
        VStack(spacing: 9) {
            Image(systemName: symbol).font(.title3).foregroundStyle(color)
            Text("\(value)").font(.system(size: 28, weight: .heavy))
            Text(title).font(.system(size: 10, weight: .bold)).foregroundStyle(Palette.muted)
        }.frame(maxWidth: .infinity).padding(.vertical, 20).background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 22))
    }
}

private struct ProfileEditor: View {
    @State var profile: AccountProfile
    let onSave: (AccountProfile) -> Void
    @Environment(\.dismiss) private var dismiss
    private let avatars = ["person.fill", "bolt.fill", "flame.fill", "star.fill", "heart.fill", "moon.stars.fill", "sun.max.fill", "mountain.2.fill"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                StudioHeader(title: "A bit of you", subtitle: "Choose your look. Tell your story.", close: { dismiss() })
                WorkoutBadge(symbol: profile.avatar, tint: Palette.purple, size: 90).frame(maxWidth: .infinity)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(avatars, id: \.self) { avatar in
                        Button { profile.avatar = avatar } label: {
                            WorkoutBadge(symbol: avatar, tint: profile.avatar == avatar ? Palette.purple : Palette.muted, size: 55)
                                .overlay(alignment: .bottomTrailing) { if profile.avatar == avatar { Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.purple).background(Palette.surface, in: Circle()) } }
                        }.accessibilityLabel(avatar.replacingOccurrences(of: ".", with: " "))
                    }
                }
                StudioField(title: "Display name", placeholder: "What should we call you?", text: $profile.displayName)
                StudioField(title: "Username", placeholder: "your_name", text: $profile.username)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                StudioField(title: "Bio", placeholder: "What keeps you moving?", text: $profile.bio)
                Button {
                    profile.displayName = String(profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40))
                    profile.username = String(profile.username.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" }.prefix(30))
                    profile.bio = String(profile.bio.prefix(160))
                    onSave(profile); dismiss()
                } label: { Label("Save profile", systemImage: "checkmark").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle())
            }.padding(24)
        }.background(Palette.background).fontDesign(.rounded).foregroundStyle(Palette.ink)
    }
}
