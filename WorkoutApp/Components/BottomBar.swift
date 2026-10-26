import SwiftUI

struct BottomBar: View {
    @Binding var tab: Int
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                tabButton("Workouts", symbol: "dumbbell.fill", value: 0)
                tabButton("Search", symbol: "magnifyingglass", value: 1)
                tabButton("Food", symbol: "viewfinder", value: 2)
            }.padding(6).background(Palette.surface, in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Palette.line, lineWidth: 1.5))
            Button { withAnimation(.easeInOut(duration: 0.18)) { tab = 3 } } label: {
                Image(systemName: tab == 3 ? "person.crop.circle.fill" : "person.crop.circle").font(.system(size: 25, weight: .bold)).frame(width: 58, height: 62)
                    .foregroundStyle(tab == 3 ? Palette.background : Palette.purple).background(tab == 3 ? Palette.purple : Palette.purple.opacity(0.13), in: RoundedRectangle(cornerRadius: 20))

            }.accessibilityLabel("Account")
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

}
