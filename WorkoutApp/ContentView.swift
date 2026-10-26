import SwiftUI

/// App shell: navigation and shared state only. Each tab lives in Features/.
struct ContentView: View {
    @StateObject private var store = AppStore()
    @State private var tab = 0
    @State private var creatingPlan = false
    @State private var showingSplash = true

    var body: some View {
        Group {
            if showingSplash { CadenceSplash() }
            else if store.trainingSetup == nil { OnboardingView(store: store) }
            else { appContent }
        }
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .tint(Palette.blue)
        .preferredColorScheme(store.profile.appearance == "system" ? nil : store.profile.appearance == "dark" ? .dark : .light)
        .task {
            guard showingSplash else { return }
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            showingSplash = false
        }
    }

    private var appContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch tab {
                    case 1: LibraryView(store: store)
                    case 2: FoodView(store: store)
                    case 3: AccountView(store: store)
                    default: WorkoutsView(store: store) { creatingPlan = true }
                    }
                }
                .padding(24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Palette.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomBar(tab: $tab)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $creatingPlan) {
                PlanEditor(plan: WorkoutPlan()) { store.save($0); tab = 0 }
            }
        }
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .tint(Palette.blue)
        .preferredColorScheme(store.profile.appearance == "system" ? nil : store.profile.appearance == "dark" ? .dark : .light)
    }
}

#Preview { ContentView() }
