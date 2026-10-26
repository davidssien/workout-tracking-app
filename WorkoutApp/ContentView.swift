import SwiftUI
import PhotosUI
import Vision

private enum Palette {
    static let blue = Color(red: 0.12, green: 0.64, blue: 0.91)
    static let darkBlue = Color(red: 0.04, green: 0.45, blue: 0.72)
    static let ink = Color(red: 0.14, green: 0.25, blue: 0.33)
    static let muted = Color(red: 0.48, green: 0.59, blue: 0.65)
    static let pale = Color(red: 0.89, green: 0.96, blue: 1)
    static let background = Color(red: 0.97, green: 0.99, blue: 1)
    static let line = Color(red: 0.85, green: 0.91, blue: 0.94)
}

private struct Workout: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let minutes: Int
    let symbol: String
    let exercises: [String]

    static let suggestions = [
        Workout(id: "full", name: "Full body fresh start", subtitle: "A little of everything. A lot of good.", minutes: 15, symbol: "figure.strengthtraining.functional", exercises: ["March in place · 2 min", "Bodyweight squats · 3 × 10", "Wall push-ups · 3 × 10", "Standing knee raises · 3 × 12", "Gentle stretch · 2 min"]),
        Workout(id: "core", name: "Your daily core", subtitle: "Small moves. Strong foundation.", minutes: 10, symbol: "figure.core.training", exercises: ["Standing side bends · 2 × 12", "Dead bugs · 3 × 10", "Bird dogs · 3 × 10", "Plank · 3 × 20 sec"]),
        Workout(id: "move", name: "Make your move", subtitle: "Find your rhythm. Feel the energy.", minutes: 20, symbol: "figure.walk", exercises: ["Easy walk · 3 min", "Brisk walk · 14 min", "Cool-down walk · 3 min"]),
        Workout(id: "stretch", name: "Stretch & reset", subtitle: "A deep breath for your whole body.", minutes: 8, symbol: "figure.cooldown", exercises: ["Shoulder rolls · 1 min", "Standing side stretch · 2 min", "Seated hamstring stretch · 2 min", "Gentle spinal twist · 2 min", "Slow breathing · 1 min"])
    ]
}

private struct FoodEntry: Codable, Identifiable {
    var id = UUID()
    var name: String
    var calories: Int
    var date = Date()
}

struct ContentView: View {
    @AppStorage("workout.completedDays") private var completedDays = ""
    @AppStorage("workout.foodEntries") private var foodData = Data()
    @State private var tab = 0
    @State private var query = ""
    @State private var selectedWorkout: Workout?
    @State private var showAdd = false
    @State private var showFood = false

    private var days: Set<String> { Set(completedDays.split(separator: ",").map(String.init)) }
    private var todayDone: Bool { days.contains(dayKey(Date())) }
    private var streak: Int {
        let calendar = Calendar.current
        var date = Date()
        if !todayDone { date = calendar.date(byAdding: .day, value: -1, to: date)! }
        var count = 0
        while days.contains(dayKey(date)) {
            count += 1
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        return count
    }
    private var foods: [FoodEntry] { (try? JSONDecoder().decode([FoodEntry].self, from: foodData)) ?? [] }
    private var todayFoods: [FoodEntry] { foods.filter { Calendar.current.isDateInToday($0.date) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                header
                if tab == 0 { home }
                else if tab == 1 { search }
                else { food }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 28)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.background)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .preferredColorScheme(.light)
        .sheet(item: $selectedWorkout) { workout in
            WorkoutDetail(workout: workout) {
                var updated = days
                updated.insert(dayKey(Date()))
                completedDays = updated.sorted().joined(separator: ",")
            }
        }
        .sheet(isPresented: $showFood) {
            FoodForm { entry in
                var updated = foods
                updated.append(entry)
                foodData = (try? JSONEncoder().encode(updated)) ?? Data()
            }
        }
        .confirmationDialog("Make a little progress", isPresented: $showAdd, titleVisibility: .visible) {
            Button("Find a workout") { tab = 1 }
            Button("Log food") { showFood = true }
            Button("Cancel", role: .cancel) { }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "dumbbell.fill").rotationEffect(.degrees(-25))
                Text("little reps").tracking(-1)
            }
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(Palette.blue)
            Spacer()
            Text(Date(), format: .dateTime.month(.abbreviated).day())
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(.white, in: Capsule())
                .overlay(Capsule().stroke(Palette.line, lineWidth: 1.5))
        }
    }

    private var home: some View {
        VStack(alignment: .leading, spacing: 24) {
            streakCard
            VStack(alignment: .leading, spacing: 6) {
                Text("Welcome back, David!").font(.system(size: 25, weight: .heavy))
                Text("A little stronger, one day at a time.")
                    .font(.system(size: 14, weight: .medium)).foregroundStyle(Palette.muted)
            }
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("MADE FOR YOUR MOMENT").font(.system(size: 11, weight: .heavy)).tracking(1.5)
                    Spacer()
                    Text("4 workouts").font(.system(size: 11, weight: .semibold))
                }.foregroundStyle(Palette.muted)
                ForEach(Array(Workout.suggestions.enumerated()), id: \.element.id) { index, workout in
                    workoutCard(workout, index: index)
                }
                Button { tab = 1 } label: {
                    Label("Explore more workouts", systemImage: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                }
                .foregroundStyle(Palette.blue)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.line, style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
                .padding(.top, 3)
            }
            HStack(spacing: 6) {
                Image(systemName: "heart.fill").foregroundStyle(Palette.blue)
                Text("Progress feels good. Keep it little.")
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Palette.muted).frame(maxWidth: .infinity)
        }
    }

    private var streakCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 17) {
                ZStack {
                    Circle().fill(.white.opacity(0.7)).frame(width: 76, height: 76)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Palette.blue.gradient)
                        .shadow(color: Palette.blue.opacity(0.2), radius: 0, y: 4)
                    Image(systemName: "sparkle").font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.blue).offset(x: 31, y: -28)
                }.accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text("\(streak)").font(.system(size: 42, weight: .heavy))
                        Text("day streak").font(.system(size: 19, weight: .heavy))
                    }
                    Text(todayDone ? "You showed up. See you tomorrow!" : streak == 0 ? "Your next little win starts today." : "Keep your spark going today!")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.darkBlue)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    let date = weekDate(index)
                    let done = days.contains(dayKey(date))
                    let today = Calendar.current.isDateInToday(date)
                    VStack(spacing: 7) {
                        Text(date, format: .dateTime.weekday(.narrow))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(today ? Palette.darkBlue : Palette.muted)
                        ZStack {
                            Circle().fill(done ? Palette.blue : .white.opacity(0.8))
                            Circle().stroke(today ? Palette.blue : .clear, lineWidth: 2)
                            if done { Image(systemName: "checkmark").font(.system(size: 13, weight: .heavy)).foregroundStyle(.white) }
                            else { Circle().fill(today ? Palette.blue : Palette.line).frame(width: 6, height: 6) }
                        }.frame(width: 30, height: 30)
                    }.frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted)), \(done ? "completed" : "not completed")")
                }
            }
        }
        .padding(20)
        .background(Palette.pale.gradient, in: RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color(red: 0.75, green: 0.88, blue: 0.96), lineWidth: 2))
        .shadow(color: Color(red: 0.75, green: 0.88, blue: 0.96), radius: 0, y: 4)
    }

    private func workoutCard(_ workout: Workout, index: Int) -> some View {
        Button { selectedWorkout = workout } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 17).fill(index % 2 == 0 ? Palette.pale : Color(red: 0.93, green: 0.96, blue: 1))
                    Image(systemName: workout.symbol).font(.system(size: 30, weight: .medium)).foregroundStyle(Palette.blue)
                }.frame(width: 62, height: 66)
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.name).font(.system(size: 16, weight: .heavy)).foregroundStyle(Palette.ink)
                    Text(workout.subtitle).font(.system(size: 10, weight: .medium)).foregroundStyle(Palette.muted)
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                        Text("\(workout.minutes) min")
                        Text("·  No equipment")
                    }.font(.system(size: 10, weight: .bold)).foregroundStyle(Palette.darkBlue)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .heavy)).foregroundStyle(Palette.blue)
            }.padding(14)
        }
        .buttonStyle(CardButtonStyle())
    }

    private var search: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Find your next little win.").font(.system(size: 30, weight: .heavy))
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(Palette.blue)
                TextField("Search workouts", text: $query).autocorrectionDisabled()
                if !query.isEmpty { Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Clear search") }
            }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line, lineWidth: 2))
            let results = Workout.suggestions.filter { query.isEmpty || "\($0.name) \($0.subtitle) \($0.exercises.joined(separator: " "))".localizedCaseInsensitiveContains(query) }
            Text("\(results.count) WORKOUTS TO FEEL GOOD ABOUT").font(.system(size: 11, weight: .heavy)).tracking(1).foregroundStyle(Palette.muted)
            ForEach(results) { workout in workoutCard(workout, index: 0) }
            if results.isEmpty {
                Text("No matches yet. Try “core”, “walk”, or “stretch”.").foregroundStyle(Palette.muted).padding(.vertical, 20)
            }
        }
    }

    private var food: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Fuel your little wins.").font(.system(size: 30, weight: .heavy))
            VStack(alignment: .leading, spacing: 12) {
                Label("TODAY’S FOOD LOG", systemImage: "fork.knife").font(.system(size: 12, weight: .heavy)).tracking(1)
                Text("\(todayFoods.reduce(0) { $0 + $1.calories })").font(.system(size: 48, weight: .heavy)) + Text(" kcal").font(.system(size: 18, weight: .bold))
                Text("A little awareness, one meal at a time.").font(.system(size: 13, weight: .medium))
            }.foregroundStyle(Palette.darkBlue).frame(maxWidth: .infinity, alignment: .leading).padding(24)
                .background(Palette.pale, in: RoundedRectangle(cornerRadius: 24))
            Button { showFood = true } label: {
                Label("Scan a label or log food", systemImage: "viewfinder")
                    .frame(maxWidth: .infinity)
            }.buttonStyle(PrimaryButtonStyle())
            Text("Scan a nutrition-label photo, then confirm the calories for your portion.")
                .font(.system(size: 13)).foregroundStyle(Palette.muted)
            if todayFoods.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "carrot.fill").font(.system(size: 36)).foregroundStyle(Palette.blue)
                    Text("A fresh page for today").font(.headline)
                    Text("Your logged meals will appear here.").font(.subheadline).foregroundStyle(Palette.muted)
                }.frame(maxWidth: .infinity).padding(.vertical, 35)
            }
            ForEach(todayFoods) { entry in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.name).font(.headline)
                        Text("\(entry.calories) kcal").font(.subheadline).foregroundStyle(Palette.muted)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        foodData = (try? JSONEncoder().encode(foods.filter { $0.id != entry.id })) ?? Data()
                    } label: { Image(systemName: "trash").padding(10) }.accessibilityLabel("Delete \(entry.name)")
                }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                tabButton("Workouts", symbol: "dumbbell.fill", value: 0)
                tabButton("Search", symbol: "magnifyingglass", value: 1)
                tabButton("Food", symbol: "viewfinder", value: 2)
            }.padding(6).background(.white, in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Palette.line, lineWidth: 1.5))
            Button { showAdd = true } label: {
                Image(systemName: "plus").font(.system(size: 25, weight: .bold)).frame(width: 58, height: 62)
                    .foregroundStyle(.white).background(Palette.blue, in: RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Palette.darkBlue, radius: 0, y: 4)
            }.accessibilityLabel("Add workout or food")
        }.padding(.horizontal, 22).padding(.top, 12).padding(.bottom, 10)
            .background(Palette.background.opacity(0.98))
    }

    private func tabButton(_ name: String, symbol: String, value: Int) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.18)) { tab = value } } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 21, weight: .bold))
                Text(name).font(.system(size: 9, weight: .heavy))
            }.frame(maxWidth: .infinity).padding(.vertical, 9)
                .foregroundStyle(tab == value ? Palette.blue : Palette.muted)
                .background(tab == value ? Palette.pale : .clear, in: RoundedRectangle(cornerRadius: 18))
        }.accessibilityAddTraits(tab == value ? .isSelected : [])
    }

    private func dayKey(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year!)-\(parts.month!)-\(parts.day!)"
    }

    private func weekDate(_ index: Int) -> Date {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        return calendar.date(byAdding: .day, value: index, to: start)!
    }
}

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.white, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Palette.line, lineWidth: 1.5))
            .shadow(color: Palette.line, radius: 0, y: configuration.isPressed ? 1 : 4)
            .offset(y: configuration.isPressed ? 3 : 0)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 16, weight: .heavy, design: .rounded))
            .padding(18).foregroundStyle(.white)
            .background(Palette.blue, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: Palette.darkBlue, radius: 0, y: configuration.isPressed ? 0 : 4)
            .offset(y: configuration.isPressed ? 4 : 0)
    }
}

private struct WorkoutDetail: View {
    let workout: Workout
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var started = false
    @State private var completed = false
    @State private var checked: Set<Int> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: completed ? "checkmark.seal.fill" : workout.symbol)
                        .font(.system(size: 64)).foregroundStyle(Palette.blue)
                        .frame(maxWidth: .infinity).padding(28).background(Palette.pale, in: RoundedRectangle(cornerRadius: 24))
                    Text(completed ? "That’s a little win!" : workout.name).font(.system(size: 30, weight: .heavy))
                    Text(completed ? "Workout saved. Your streak is up to date." : "\(workout.minutes) minutes · No equipment\nMove at your own pace and rest when you need to.")
                        .foregroundStyle(Palette.muted)
                    if !completed {
                        ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                            Button {
                                if started {
                                    if checked.contains(index) { checked.remove(index) } else { checked.insert(index) }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: checked.contains(index) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(Palette.blue)
                                    Text(exercise).foregroundStyle(Palette.ink)
                                    Spacer()
                                }.padding(.vertical, 10)
                            }.disabled(!started)
                        }
                    }
                    Button {
                        if completed { dismiss() }
                        else if !started { started = true }
                        else { onComplete(); completed = true }
                    } label: {
                        Text(completed ? "Keep feeling good" : started ? "Finish workout" : "Let’s do this")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(PrimaryButtonStyle())
                        .disabled(started && !completed && checked.count != workout.exercises.count)
                        .opacity(started && !completed && checked.count != workout.exercises.count ? 0.45 : 1)
                    if started && !completed {
                        Text("Tap each exercise as you complete it.").font(.footnote).foregroundStyle(Palette.muted)
                    }
                }.padding(24)
            }.background(Palette.background).fontDesign(.rounded)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { dismiss() } } }
        }.tint(Palette.blue)
    }
}

private struct FoodForm: View {
    let onSave: (FoodEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var calories = ""
    @State private var photo: PhotosPickerItem?
    @State private var scanning = false
    @State private var scanMessage = "Choose a clear photo of the nutrition label."

    private var valid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (Int(calories) ?? 0) > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $photo, matching: .images) {
                        Label(scanning ? "Reading label…" : "Scan nutrition-label photo", systemImage: "viewfinder")
                    }.disabled(scanning)
                    Text(scanMessage).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Confirm your portion") {
                    TextField("Food or meal name", text: $name)
                    TextField("Calories (kcal)", text: $calories).keyboardType(.numberPad)
                    Text("Check the serving size and adjust calories to match how much you ate.").font(.footnote).foregroundStyle(.secondary)
                }
                Section {
                    Button("Save food") {
                        guard let value = Int(calories), valid else { return }
                        onSave(FoodEntry(name: name.trimmingCharacters(in: .whitespacesAndNewlines), calories: value))
                        dismiss()
                    }.disabled(!valid || scanning)
                }
            }.navigationTitle("A little fuel").fontDesign(.rounded)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
                .task(id: photo) { await scanPhoto() }
        }.tint(Palette.blue)
    }

    private func scanPhoto() async {
        guard let photo else { return }
        scanning = true
        defer { scanning = false }
        do {
            guard let data = try await photo.loadTransferable(type: Data.self) else { throw ScanError.unreadable }
            let text = try await Task.detached(priority: .userInitiated) {
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                try VNImageRequestHandler(data: data).perform([request])
                return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            }.value
            guard !Task.isCancelled else { return }
            let regex = try NSRegularExpression(pattern: "(?i)calories[\\s:]*([0-9]{1,4})\\b")
            if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)), let range = Range(match.range(at: 1), in: text) {
                calories = String(text[range])
                scanMessage = "Calories found. Confirm the value and serving size before saving."
            } else {
                scanMessage = "Couldn’t find a clear calorie value. You can enter it from the label below."
            }
        } catch {
            scanMessage = "This photo couldn’t be read. Try another photo or enter calories manually."
        }
    }

    private enum ScanError: Error { case unreadable }
}

#Preview {
    ContentView()
}
