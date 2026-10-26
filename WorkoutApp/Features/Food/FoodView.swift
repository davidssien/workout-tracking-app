import SwiftUI

struct FoodView: View {
    @ObservedObject var store: AppStore
    @State private var showFood = false
    private var todayFoods: [FoodEntry] { store.foods.filter { Calendar.current.isDateInToday($0.date) } }
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Fuel your little wins.").font(.system(size: 30, weight: .heavy))
            VStack(alignment: .leading, spacing: 12) {
                Label("TODAY’S FOOD LOG", systemImage: "fork.knife").font(.system(size: 12, weight: .heavy)).tracking(1)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(todayFoods.reduce(0) { $0 + $1.calories })").font(.system(size: 48, weight: .heavy))
                    Text("kcal").font(.system(size: 18, weight: .bold))
                }
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
                        store.deleteFood(entry.id)
                    } label: { Image(systemName: "trash").padding(10) }.accessibilityLabel("Delete \(entry.name)")
                }.padding(16).background(Palette.surface, in: RoundedRectangle(cornerRadius: 18))
            }
        }.sheet(isPresented: $showFood) { FoodForm { store.addFood($0) } }
    }

}
