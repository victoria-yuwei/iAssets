import Foundation
import SwiftData

@Model
final class AssetItem {
    var id: UUID
    var name: String
    var categoryRaw: String
    var statusRaw: String
    var tagsCSV: String
    var purchasePrice: Double
    var purchaseCurrency: String
    var purchaseDate: Date
    var targetDailyCost: Double?
    var currentValuation: Double?
    var valuationCurrency: String?
    var note: String
    var imageData: Data?
    var soldPrice: Double?
    var soldCurrency: String?
    var soldDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        name: String,
        category: AssetCategory = .digital,
        status: AssetStatus = .inService,
        tags: [String] = [],
        purchasePrice: Double,
        purchaseCurrency: String = "CNY",
        purchaseDate: Date = .now,
        targetDailyCost: Double? = nil,
        currentValuation: Double? = nil,
        valuationCurrency: String? = nil,
        note: String = "",
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.statusRaw = status.rawValue
        self.tagsCSV = tags.joined(separator: ",")
        self.purchasePrice = purchasePrice
        self.purchaseCurrency = purchaseCurrency
        self.purchaseDate = purchaseDate
        self.targetDailyCost = targetDailyCost
        self.currentValuation = currentValuation
        self.valuationCurrency = valuationCurrency
        self.note = note
        self.imageData = imageData
        self.soldPrice = nil
        self.soldCurrency = nil
        self.soldDate = nil
        self.createdAt = .now
        self.updatedAt = .now
    }

    var category: AssetCategory {
        get { AssetCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var status: AssetStatus {
        get { AssetStatus(rawValue: statusRaw) ?? .inService }
        set { statusRaw = newValue.rawValue }
    }

    var tags: [String] {
        get {
            tagsCSV
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set { tagsCSV = newValue.joined(separator: ",") }
    }

    var endDateForHolding: Date {
        if status == .sold, let soldDate {
            return soldDate
        }
        return Date()
    }

    var holdingDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: purchaseDate)
        let end = calendar.startOfDay(for: endDateForHolding)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(days, 1)
    }
}
