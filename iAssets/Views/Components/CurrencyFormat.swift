import Foundation

enum CurrencyFormat {
    static func string(_ value: Double, code: String, fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f %@", value, code)
    }

    static func compact(_ value: Double, code: String) -> String {
        string(value, code: code, fractionDigits: abs(value) >= 100 ? 0 : 2)
    }
}
