import Foundation

enum AssetCalculator {
    static func amountInBase(
        amount: Double,
        currency: String,
        baseCurrency: String,
        rates: ExchangeRateService
    ) -> Double {
        rates.convert(amount: amount, from: currency, to: baseCurrency)
    }

    static func purchaseInBase(_ item: AssetItem, base: String, rates: ExchangeRateService) -> Double {
        amountInBase(amount: item.purchasePrice, currency: item.purchaseCurrency, baseCurrency: base, rates: rates)
    }

    static func valuationInBase(_ item: AssetItem, base: String, rates: ExchangeRateService) -> Double {
        guard let valuation = item.currentValuation else {
            return purchaseInBase(item, base: base, rates: rates)
        }
        let currency = item.valuationCurrency ?? item.purchaseCurrency
        return amountInBase(amount: valuation, currency: currency, baseCurrency: base, rates: rates)
    }

    static func displayValue(
        _ item: AssetItem,
        mode: ValuationMode,
        base: String,
        rates: ExchangeRateService
    ) -> Double {
        switch mode {
        case .cost:
            return purchaseInBase(item, base: base, rates: rates)
        case .valuation:
            return valuationInBase(item, base: base, rates: rates)
        }
    }

    static func dailyCost(_ item: AssetItem, base: String, rates: ExchangeRateService) -> Double {
        let purchase = purchaseInBase(item, base: base, rates: rates)
        if item.status == .sold, let soldPrice = item.soldPrice {
            let soldCurrency = item.soldCurrency ?? item.purchaseCurrency
            let sold = amountInBase(amount: soldPrice, currency: soldCurrency, baseCurrency: base, rates: rates)
            return (purchase - sold) / Double(item.holdingDays)
        }
        return purchase / Double(item.holdingDays)
    }

    static func isPaidBack(_ item: AssetItem, base: String, rates: ExchangeRateService) -> Bool? {
        guard let target = item.targetDailyCost else { return nil }
        return dailyCost(item, base: base, rates: rates) <= target
    }

    static func profitLoss(_ item: AssetItem, base: String, rates: ExchangeRateService) -> Double? {
        guard item.status == .sold, let soldPrice = item.soldPrice else { return nil }
        let purchase = purchaseInBase(item, base: base, rates: rates)
        let soldCurrency = item.soldCurrency ?? item.purchaseCurrency
        let sold = amountInBase(amount: soldPrice, currency: soldCurrency, baseCurrency: base, rates: rates)
        return sold - purchase
    }

    static func netWorth(
        items: [AssetItem],
        mode: ValuationMode,
        base: String,
        rates: ExchangeRateService,
        includeSold: Bool
    ) -> Double {
        items
            .filter { includeSold || $0.status != .sold }
            .map { displayValue($0, mode: mode, base: base, rates: rates) }
            .reduce(0, +)
    }

    static func totalsByCategory(
        items: [AssetItem],
        mode: ValuationMode,
        base: String,
        rates: ExchangeRateService,
        includeSold: Bool
    ) -> [(AssetCategory, Double)] {
        var map: [AssetCategory: Double] = [:]
        for item in items where includeSold || item.status != .sold {
            let value = displayValue(item, mode: mode, base: base, rates: rates)
            map[item.category, default: 0] += value
        }
        return map.sorted { $0.value > $1.value }
    }

    static func serviceProgress(purchaseDate: Date, expectedYears: Double = 3) -> Double {
        let days = max(
            Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: purchaseDate),
                to: Calendar.current.startOfDay(for: Date())
            ).day ?? 0,
            0
        )
        let total = expectedYears * 365
        return min(Double(days) / total, 1)
    }
}
