import SwiftUI

/// The three staggered beats are a vector mark, crisp at every size and in both themes.
struct CadenceMark: View {
    var size: CGFloat = 72
    var body: some View {
        HStack(alignment: .center, spacing: size * 0.09) {
            Capsule().fill(Palette.blue).frame(width: size * 0.18, height: size * 0.43).offset(y: size * 0.16)
            Capsule().fill(Palette.purple).frame(width: size * 0.18, height: size * 0.78)
            Capsule().fill(Palette.mint).frame(width: size * 0.18, height: size * 0.54).offset(y: -size * 0.12)
        }.rotationEffect(.degrees(18)).frame(width: size, height: size).accessibilityHidden(true)
    }
}

struct CadenceSplash: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            CadenceMark(size: 108).scaleEffect(appeared ? 1 : 0.82)
            VStack(spacing: 10) {
                Text("Cadence").font(.system(size: 42, weight: .heavy, design: .rounded)).tracking(-1.5)
                Text("YOUR MOVES. YOUR RHYTHM.").font(.system(size: 10, weight: .heavy)).tracking(2.5).foregroundStyle(Palette.muted)
            }
            Spacer()
            HStack(spacing: 6) {
                ForEach(0..<3) { index in Circle().fill([Palette.blue, Palette.purple, Palette.mint][index]).frame(width: 6, height: 6) }
            }.padding(.bottom, 40)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Palette.background).foregroundStyle(Palette.ink)
            .onAppear { withAnimation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.65)) { appeared = true } }
    }
}
