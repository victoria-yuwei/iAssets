import SwiftUI
import SwiftData

struct ReviewView: View {
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var rates: ExchangeRateService
    @Query(sort: \AssetItem.updatedAt, order: .reverse) private var items: [AssetItem]

    private var sold: [AssetItem] {
        items.filter { $0.status == .sold }
    }

    private var active: [AssetItem] {
        items.filter { $0.status != .sold }
    }

    private var totalPL: Double {
        sold.compactMap { AssetCalculator.profitLoss($0, base: settings.baseCurrency, rates: rates) }
            .reduce(0, +)
    }

    private var dailyRanking: [AssetItem] {
        active.sorted {
            AssetCalculator.dailyCost($0, base: settings.baseCurrency, rates: rates)
                > AssetCalculator.dailyCost($1, base: settings.baseCurrency, rates: rates)
        }
    }

    private var dusty: [AssetItem] {
        active.filter {
            $0.status == .retired || AssetCalculator.serviceProgress(purchaseDate: $0.purchaseDate) > 0.6
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("已卖出件数", value: "\(sold.count)")
                    LabeledContent(
                        "累计盈亏",
                        value: CurrencyFormat.string(totalPL, code: settings.baseCurrency)
                    )
                } header: {
                    Text("变现汇总")
                }

                Section("已卖出列表") {
                    if sold.isEmpty {
                        Text("还没有变现记录")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(sold) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    if let pl = AssetCalculator.profitLoss(item, base: settings.baseCurrency, rates: rates) {
                                        Text(CurrencyFormat.string(pl, code: settings.baseCurrency))
                                            .font(.caption)
                                            .foregroundStyle(pl >= 0 ? .green : .red)
                                    }
                                }
                                Spacer()
                                StatusChip(status: .sold)
                            }
                        }
                    }
                }

                Section("日耗排行（未卖出）") {
                    ForEach(dailyRanking.prefix(10)) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(
                                CurrencyFormat.compact(
                                    AssetCalculator.dailyCost(item, base: settings.baseCurrency, rates: rates),
                                    code: settings.baseCurrency
                                )
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("闲置 / 长持提醒") {
                    if dusty.isEmpty {
                        Text("暂无明显闲置项")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(dusty.prefix(10)) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                StatusChip(status: item.status)
                            }
                        }
                    }
                }

                Section("分类花费（按成本）") {
                    let pairs = AssetCalculator.totalsByCategory(
                        items: items,
                        mode: .cost,
                        base: settings.baseCurrency,
                        rates: rates,
                        includeSold: true
                    )
                    ForEach(pairs, id: \.0) { pair in
                        HStack {
                            Label(pair.0.title, systemImage: pair.0.systemImage)
                            Spacer()
                            Text(CurrencyFormat.compact(pair.1, code: settings.baseCurrency))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("复盘")
        }
    }
}
