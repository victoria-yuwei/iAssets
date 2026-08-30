import Foundation
import Combine

@MainActor
final class ExchangeRateService: ObservableObject {
    static let shared = ExchangeRateService()

    /// Rates relative to USD: 1 USD = rates[currency] units of that currency.
    @Published private(set) var ratesVersusUSD: [String: Double] = ["USD": 1]
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    private let defaults = UserDefaults.standard
    private let cacheRatesKey = "fx.ratesVersusUSD"
    private let cacheDateKey = "fx.lastUpdated"
    private let sessionDayKey = "fx.sessionDay"

    private init() {
        if let data = defaults.data(forKey: cacheRatesKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            ratesVersusUSD = decoded
        }
        lastUpdated = defaults.object(forKey: cacheDateKey) as? Date
        if ratesVersusUSD["USD"] == nil {
            ratesVersusUSD["USD"] = 1
        }
        // Seed approximate fallbacks so offline first launch still works.
        if ratesVersusUSD.count < 3 {
            ratesVersusUSD.merge([
                "USD": 1,
                "CNY": 7.2,
                "EUR": 0.92,
                "JPY": 150,
                "GBP": 0.79,
                "HKD": 7.8,
                "TWD": 32,
                "SGD": 1.34,
                "AUD": 1.52,
                "CAD": 1.36,
                "CHF": 0.88,
                "KRW": 1350
            ]) { current, _ in current }
        }
    }

    func refreshIfNeeded(force: Bool) async {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSession = defaults.object(forKey: sessionDayKey) as? Date
        if !force, let lastSession, Calendar.current.isDate(lastSession, inSameDayAs: today), lastUpdated != nil {
            return
        }
        await refresh()
        defaults.set(today, forKey: sessionDayKey)
    }

    func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        // Frankfurter (ECB) — free, no API key. Base USD for a full cross table.
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=USD") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let payload = try JSONDecoder().decode(FrankfurterResponse.self, from: data)
            // Merge so currencies missing from Frankfurter (e.g. TWD) keep cached/seed rates.
            var map = ratesVersusUSD
            map.merge(payload.rates) { _, new in new }
            map["USD"] = 1
            ratesVersusUSD = map
            lastUpdated = Date()
            if let encoded = try? JSONEncoder().encode(map) {
                defaults.set(encoded, forKey: cacheRatesKey)
            }
            defaults.set(lastUpdated, forKey: cacheDateKey)
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Convert `amount` in `from` into `to` using USD-cross rates.
    func convert(amount: Double, from: String, to: String) -> Double {
        let fromCode = from.uppercased()
        let toCode = to.uppercased()
        if fromCode == toCode { return amount }
        guard let fromRate = ratesVersusUSD[fromCode], fromRate > 0,
              let toRate = ratesVersusUSD[toCode], toRate > 0 else {
            return amount
        }
        let inUSD = amount / fromRate
        return inUSD * toRate
    }

    var lastUpdatedText: String {
        guard let lastUpdated else { return "尚未更新" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdated)
    }
}

private struct FrankfurterResponse: Decodable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}
