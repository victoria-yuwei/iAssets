import SwiftUI
import SwiftData

struct CabinetView: View {
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var rates: ExchangeRateService
    @Query(sort: \AssetItem.updatedAt, order: .reverse) private var items: [AssetItem]

    @State private var search = ""
    @State private var statusFilter: AssetStatus? = nil
    @State private var categoryFilter: AssetCategory? = nil
    @State private var isGrid = true

    private var filtered: [AssetItem] {
        items.filter { item in
            if let statusFilter, item.status != statusFilter { return false }
            if let categoryFilter, item.category != categoryFilter { return false }
            if search.isEmpty { return true }
            let q = search.lowercased()
            return item.name.lowercased().contains(q)
                || item.tags.contains { $0.lowercased().contains(q) }
                || item.category.title.contains(search)
        }
    }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "陈列柜是空的",
                        systemImage: "square.grid.2x2",
                        description: Text("添加你的第一件资产，开始万物资产化。")
                    )
                } else if isGrid {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filtered) { item in
                                NavigationLink(value: item.id) {
                                    AssetCardView(
                                        item: item,
                                        baseCurrency: settings.baseCurrency,
                                        mode: settings.valuationMode,
                                        rates: rates,
                                        isGrid: true
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                } else {
                    List(filtered) { item in
                        NavigationLink(value: item.id) {
                            AssetCardView(
                                item: item,
                                baseCurrency: settings.baseCurrency,
                                mode: settings.valuationMode,
                                rates: rates,
                                isGrid: false
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("陈列柜")
            .searchable(text: $search, prompt: "搜索名称 / 标签")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("全部状态") { statusFilter = nil }
                        ForEach(AssetStatus.allCases) { s in
                            Button(s.title) { statusFilter = s }
                        }
                        Divider()
                        Button("全部分类") { categoryFilter = nil }
                        ForEach(AssetCategory.allCases) { c in
                            Button(c.title) { categoryFilter = c }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isGrid.toggle()
                    } label: {
                        Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                if let item = items.first(where: { $0.id == id }) {
                    AssetDetailView(item: item)
                } else {
                    Text("资产不存在")
                }
            }
        }
    }
}

extension AssetItem: Identifiable {}
