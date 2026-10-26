import SwiftUI

struct ImportPlanView: View {
    let onImport: (WorkoutPlan) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var preview: WorkoutPlan?
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                StudioHeader(title: "Pass the good energy", subtitle: "Import a workout someone shared with you.", close: { dismiss() })
                if let preview {
                    WorkoutBadge(symbol: preview.icon ?? "dumbbell.fill", tint: WorkoutStyle.color(preview.color), size: 80)
                    Text(preview.name).font(.title.bold())
                    Text("\(preview.focus) · \(preview.exercises.count) moves").foregroundStyle(Palette.muted)
                    ForEach(preview.exercises) { item in
                        HStack { Text(item.exercise?.name ?? "").font(.headline); Spacer(); Text(item.summary).font(.caption).foregroundStyle(Palette.muted) }.padding(.vertical, 8)
                    }
                    Button { onImport(preview); dismiss() } label: { Label("Add to my rotation", systemImage: "plus.circle.fill").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle())
                    Button("Use a different plan") { self.preview = nil }.font(.headline).padding(12)
                } else {
                    Text("Paste the complete Cadence plan text below. You’ll review it before adding it.").foregroundStyle(Palette.muted)
                    TextEditor(text: $text).scrollContentBackground(.hidden).frame(minHeight: 200)
                        .padding(14).background(Palette.surface, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.line, lineWidth: 2))
                        .accessibilityLabel("Shared plan text")
                    if let error { Text(error).font(.subheadline).foregroundStyle(Palette.coral) }
                    Button {
                        do { preview = try PlanSharing.decode(text); error = nil }
                        catch { self.error = error.localizedDescription }
                    } label: { Label("Preview plan", systemImage: "arrow.right").frame(maxWidth: .infinity) }.buttonStyle(PrimaryButtonStyle()).disabled(text.isEmpty).opacity(text.isEmpty ? 0.5 : 1)
                }
            }.padding(24)
        }.background(Palette.background).fontDesign(.rounded).foregroundStyle(Palette.ink)
    }
}
