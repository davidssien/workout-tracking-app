import SwiftUI

struct StreakCard: View {
    @ObservedObject var store: AppStore
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 17) {
                ZStack {
                    Circle().fill(Palette.surface.opacity(0.7)).frame(width: 76, height: 76)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Palette.blue.gradient)
                        .shadow(color: Palette.blue.opacity(0.2), radius: 0, y: 4)
                    Image(systemName: "sparkle").font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.blue).offset(x: 31, y: -28)
                }.accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text("\(store.streak)").font(.system(size: 42, weight: .heavy))
                        Text("day streak").font(.system(size: 19, weight: .heavy))
                    }
                    Text(store.todayDone ? "You showed up. See you tomorrow!" : store.streak == 0 ? "Your next little win starts today." : "Keep your spark going today!")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.darkBlue)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    let date = weekDate(index)
                    let done = store.completedDays.contains(AppStore.dayKey(date))
                    let today = Calendar.current.isDateInToday(date)
                    VStack(spacing: 7) {
                        Text(date, format: .dateTime.weekday(.narrow))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(today ? Palette.darkBlue : Palette.muted)
                        ZStack {
                            Circle().fill(done ? Palette.blue : Palette.surface.opacity(0.8))
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
        .background(LinearGradient(colors: [Palette.pale, Palette.purple.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 26))
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Palette.blue.opacity(0.23), lineWidth: 2))
        .compositingGroup()
        .shadow(color: Palette.blue.opacity(0.23), radius: 0, y: 4)
    }

    private func weekDate(_ index: Int) -> Date {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        return calendar.date(byAdding: .day, value: index, to: start)!
    }
}
