import SwiftUI
import PhotosUI
import Vision

struct FoodForm: View {
    let onSave: (FoodEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var calories = ""
    @State private var photo: PhotosPickerItem?
    @State private var scanning = false
    @State private var scanMessage = "Choose a clear photo of the nutrition label."

    private var valid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (Int(calories) ?? 0) > 0 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                StudioHeader(title: "Fuel the good stuff", subtitle: "One meal at a time.", close: { dismiss() })
                PhotosPicker(selection: $photo, matching: .images) {
                    VStack(spacing: 16) {
                        WorkoutBadge(symbol: "viewfinder", tint: Palette.mint, size: 82)
                        Text(scanning ? "Reading your label…" : "Scan a nutrition label").font(.title3.bold())
                        Text("Choose a photo from your library").font(.subheadline).foregroundStyle(Palette.muted)
                    }.frame(maxWidth: .infinity).padding(26)
                        .background(Palette.mint.opacity(0.08), in: RoundedRectangle(cornerRadius: 26))
                        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Palette.mint.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])))
                }.disabled(scanning).foregroundStyle(Palette.ink)
                Text(scanMessage).font(.subheadline).foregroundStyle(Palette.muted)
                StudioField(title: "Food or meal", placeholder: "What’s on the menu?", text: $name)
                StudioField(title: "Calories for your portion", placeholder: "kcal", text: $calories).keyboardType(.numberPad)
                Text("Check the label’s serving size and adjust for how much you ate.").font(.caption).foregroundStyle(Palette.muted)
                Button {
                    guard let value = Int(calories), valid else { return }
                    onSave(FoodEntry(name: name.trimmingCharacters(in: .whitespacesAndNewlines), calories: value))
                    dismiss()
                } label: { Label("Save food", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(PrimaryButtonStyle()).disabled(!valid || scanning).opacity(valid && !scanning ? 1 : 0.45)
            }.padding(24)
        }.background(Palette.background).fontDesign(.rounded).foregroundStyle(Palette.ink)
            .task(id: photo) { await scanPhoto() }
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

