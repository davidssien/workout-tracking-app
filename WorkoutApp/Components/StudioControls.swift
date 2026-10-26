import SwiftUI

struct StudioHeader: View {
    let title: String
    var subtitle: String? = nil
    var close: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.system(size: 28, weight: .heavy, design: .rounded)).foregroundStyle(Palette.ink)
                if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(Palette.muted) }
            }
            Spacer(minLength: 0)
            if let close {
                Button(action: close) { Image(systemName: "xmark").font(.system(size: 15, weight: .heavy)).frame(width: 44, height: 44) }
                    .foregroundStyle(Palette.muted).background(Palette.surface, in: Circle())
                    .overlay(Circle().stroke(Palette.line, lineWidth: 1.5)).accessibilityLabel("Close")
            }
        }
    }
}

struct StudioField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased()).font(.system(size: 11, weight: .heavy)).tracking(1.5).foregroundStyle(Palette.muted)
            TextField(placeholder, text: $text)
                .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink)
                .padding(18).background(Palette.surface, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.line, lineWidth: 2))
        }
    }
}

struct ChoiceChip: View {
    let title: String
    var symbol: String? = nil
    let selected: Bool
    var tint: Color = Palette.blue
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let symbol { Image(systemName: symbol) }
                Text(title)
            }.font(.system(size: 13, weight: .bold)).padding(.horizontal, 14).padding(.vertical, 12)
                .foregroundStyle(selected ? tint : Palette.muted)
                .background(selected ? tint.opacity(0.14) : Palette.surface, in: Capsule())
                .overlay(Capsule().stroke(selected ? tint : Palette.line, lineWidth: selected ? 2 : 1))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct NumberControl: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var body: some View {
        VStack(spacing: 9) {
            Text(title.uppercased()).font(.system(size: 10, weight: .heavy)).tracking(1).foregroundStyle(Palette.muted)
            HStack(spacing: 0) {
                changeButton("minus", delta: -1)
                Text("\(value)").font(.system(size: 20, weight: .heavy)).monospacedDigit().frame(maxWidth: .infinity)
                changeButton("plus", delta: 1)
            }.padding(4).background(Palette.background, in: RoundedRectangle(cornerRadius: 14))
        }
    }
    private func changeButton(_ symbol: String, delta: Int) -> some View {
        Button { value += delta } label: {
            Image(systemName: symbol).font(.system(size: 12, weight: .heavy)).frame(width: 38, height: 40)
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: 10))
        }.disabled(!range.contains(value + delta)).accessibilityLabel("\(delta > 0 ? "Increase" : "Decrease") \(title)")
    }
}

struct WorkoutBadge: View {
    let symbol: String
    let tint: Color
    var size: CGFloat = 64
    var body: some View {
        Image(systemName: symbol).font(.system(size: size * 0.40, weight: .bold))
            .symbolRenderingMode(.hierarchical).foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: size * 0.29))
            .overlay(RoundedRectangle(cornerRadius: size * 0.29).stroke(tint.opacity(0.23), lineWidth: 1.5))
    }
}
