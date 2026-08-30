import SwiftUI
import SwiftData

struct SellAssetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var rates: ExchangeRateService

    @Bindable var item: AssetItem

    @State private var soldPriceText = ""
    @State private var soldCurrency = "CNY"
    @State private var soldDate = Date()
    @State private var note = ""

    private var previewPL: Double? {
        guard let price = Double(soldPriceText) else { return nil }
        let purchase = AssetCalculator.purchaseInBase(item, base: settings.baseCurrency, rates: rates)
        let sold = AssetCalculator.amountInBase(
            amount: price,
            currency: soldCurrency,
            baseCurrency: settings.baseCurrency,
            rates: rates
        )
        return sold - purchase
    }

    private var previewDaily: Double? {
        guard let price = Double(soldPriceText) else { return nil }
        let purchase = AssetCalculator.purchaseInBase(item, base: settings.baseCurrency, rates: rates)
        let sold = AssetCalculator.amountInBase(
            amount: price,
            currency: soldCurrency,
            baseCurrency: settings.baseCurrency,
            rates: rates
        )
        let days = max(
            Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: item.purchaseDate),
                to: Calendar.current.startOfDay(for: soldDate)
            ).day ?? 1,
            1
        )
        return (purchase - sold) / Double(days)
    }

    var body: some View {
        Form {
            Section("变现信息") {
                TextField("卖出价格", text: $soldPriceText)
                    .keyboardType(.decimalPad)
                Picker("卖出币种", selection: $soldCurrency) {
                    ForEach(SupportedCurrency.allCases) { c in
                        Text(c.title).tag(c.rawValue)
                    }
                }
                DatePicker("卖出日期", selection: $soldDate, displayedComponents: .date)
                TextField("备注（可选）", text: $note)
            }

            Section("复盘预览（\(settings.baseCurrency)）") {
                if let pl = previewPL {
                    LabeledContent("盈亏", value: CurrencyFormat.string(pl, code: settings.baseCurrency))
                }
                if let daily = previewDaily {
                    LabeledContent("修正日均成本", value: CurrencyFormat.string(daily, code: settings.baseCurrency))
                }
                if previewPL == nil {
                    Text("输入卖出价后显示复盘结果")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("登记变现")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { save() }
                    .disabled(Double(soldPriceText) == nil)
            }
        }
        .onAppear {
            soldCurrency = item.purchaseCurrency
            note = item.note
        }
    }

    private func save() {
        guard let price = Double(soldPriceText) else { return }
        item.soldPrice = price
        item.soldCurrency = soldCurrency
        item.soldDate = soldDate
        item.status = .sold
        if !note.isEmpty { item.note = note }
        item.updatedAt = .now
        try? context.save()
        dismiss()
    }
}
