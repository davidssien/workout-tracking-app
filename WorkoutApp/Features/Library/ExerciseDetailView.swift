import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    StudioHeader(title: exercise.name, close: { dismiss() })
                    HStack(spacing: 12) {
                        VStack(spacing: 14) {
                            Image(systemName: exercise.symbol).font(.system(size: 75, weight: .regular))
                                .frame(height: 170).foregroundStyle(Palette.blue)
                            Text("Movement").font(.caption.bold())
                        }.frame(maxWidth: .infinity)
                        VStack(spacing: 14) {
                            MuscleDiagram(group: exercise.group).frame(width: 100, height: 170)
                            Text("Target area").font(.caption.bold())
                        }.frame(maxWidth: .infinity)
                    }.padding(20).background(Palette.pale, in: RoundedRectangle(cornerRadius: 24))
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            ForEach(1...3, id: \.self) { level in
                                Image(systemName: level <= exercise.difficulty ? "diamond.fill" : "diamond")
                                    .foregroundStyle(Palette.blue)
                            }
                            Text(["", "Beginner", "Intermediate", "Challenging"][exercise.difficulty])
                                .font(.subheadline.bold()).padding(.leading, 6)
                        }.accessibilityElement(children: .ignore)
                            .accessibilityLabel("Difficulty \(exercise.difficulty) of 3")
                        Text(exercise.muscles).font(.subheadline).foregroundStyle(Palette.darkBlue)
                    }
                    Text("How to do it").font(.title3.bold())
                    Text(exercise.instructions).lineSpacing(6)
                    Text("The illustration shows the general movement category and target area.")
                        .font(.caption).foregroundStyle(Palette.muted)
                }.padding(24)
            }.background(Palette.background)
                .toolbar(.hidden, for: .navigationBar)
        }.tint(Palette.blue).fontDesign(.rounded)
            .presentationDetents([.large]).presentationDragIndicator(.visible)
    }
}

/// A simple front-view body map, highlighting broad regions rather than individual anatomy.
private struct MuscleDiagram: View {
    let group: String
    private func color(_ region: String) -> Color {
        group == region || group == "Full body" ? Palette.blue : Palette.line
    }

    var body: some View {
        Canvas { context, size in
            let sx = size.width / 100
            let sy = size.height / 170
            func block(_ rect: CGRect, radius: CGFloat, color: Color) {
                let scaled = CGRect(x: rect.minX * sx, y: rect.minY * sy, width: rect.width * sx, height: rect.height * sy)
                context.fill(Path(roundedRect: scaled, cornerRadius: radius), with: .color(color))
            }
            block(CGRect(x: 38, y: 0, width: 24, height: 24), radius: 12, color: Palette.muted.opacity(0.4))
            block(CGRect(x: 29, y: 30, width: 42, height: 37), radius: 10, color: color("Upper body"))
            block(CGRect(x: 32, y: 69, width: 36, height: 29), radius: 7, color: color("Core"))
            block(CGRect(x: 13, y: 32, width: 12, height: 65), radius: 6, color: color("Upper body"))
            block(CGRect(x: 75, y: 32, width: 12, height: 65), radius: 6, color: color("Upper body"))
            block(CGRect(x: 30, y: 102, width: 18, height: 67), radius: 8, color: color("Lower body"))
            block(CGRect(x: 52, y: 102, width: 18, height: 67), radius: 8, color: color("Lower body"))
        }.accessibilityLabel("\(group) highlighted on a body map")
    }
}
