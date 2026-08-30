import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("总览", systemImage: "chart.pie.fill") }
                .tag(0)

            CabinetView()
                .tabItem { Label("陈列柜", systemImage: "square.grid.2x2.fill") }
                .tag(1)

            AddAssetView(onSaved: { selectedTab = 1 })
                .tabItem { Label("添加", systemImage: "plus.circle.fill") }
                .tag(2)

            ReviewView()
                .tabItem { Label("复盘", systemImage: "arrow.triangle.2.circlepath") }
                .tag(3)

            SettingsView()
                .tabItem { Label("我的", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .tint(Color("AccentColor"))
    }
}
