import Foundation
import SwiftData
import UniformTypeIdentifiers

enum ImportExportService {
    struct ExportRow: Codable {
        var name: String
        var category: String
        var status: String
        var tags: String
        var purchasePrice: Double
        var purchaseCurrency: String
        var purchaseDate: String
        var targetDailyCost: Double?
        var currentValuation: Double?
        var valuationCurrency: String?
        var note: String
        var soldPrice: Double?
        var soldCurrency: String?
        var soldDate: String?
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func exportJSON(items: [AssetItem]) throws -> Data {
        let rows = items.map(makeRow)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(rows)
    }

    static func exportCSV(items: [AssetItem]) -> String {
        let header = [
            "name", "category", "status", "tags", "purchasePrice", "purchaseCurrency",
            "purchaseDate", "targetDailyCost", "currentValuation", "valuationCurrency",
            "note", "soldPrice", "soldCurrency", "soldDate"
        ].joined(separator: ",")
        let lines = items.map { item -> String in
            let row = makeRow(item)
            return [
                csvEscape(row.name),
                csvEscape(row.category),
                csvEscape(row.status),
                csvEscape(row.tags),
                String(row.purchasePrice),
                csvEscape(row.purchaseCurrency),
                csvEscape(row.purchaseDate),
                row.targetDailyCost.map(String.init) ?? "",
                row.currentValuation.map(String.init) ?? "",
                csvEscape(row.valuationCurrency ?? ""),
                csvEscape(row.note),
                row.soldPrice.map(String.init) ?? "",
                csvEscape(row.soldCurrency ?? ""),
                csvEscape(row.soldDate ?? "")
            ].joined(separator: ",")
        }
        return ([header] + lines).joined(separator: "\n")
    }

    static func importJSON(_ data: Data, into context: ModelContext) throws -> Int {
        let rows = try JSONDecoder().decode([ExportRow].self, from: data)
        for row in rows {
            context.insert(makeItem(from: row))
        }
        try context.save()
        return rows.count
    }

    static func importCSV(_ text: String, into context: ModelContext) throws -> Int {
        let lines = text
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard lines.count >= 2 else { return 0 }
        var count = 0
        for line in lines.dropFirst() {
            let cols = parseCSVLine(line)
            guard cols.count >= 7 else { continue }
            let row = ExportRow(
                name: cols[0],
                category: cols[1],
                status: cols[2],
                tags: cols[safe: 3] ?? "",
                purchasePrice: Double(cols[safe: 4] ?? "") ?? 0,
                purchaseCurrency: cols[safe: 5] ?? "CNY",
                purchaseDate: cols[safe: 6] ?? dateFormatter.string(from: Date()),
                targetDailyCost: Double(cols[safe: 7] ?? ""),
                currentValuation: Double(cols[safe: 8] ?? ""),
                valuationCurrency: emptyToNil(cols[safe: 9]),
                note: cols[safe: 10] ?? "",
                soldPrice: Double(cols[safe: 11] ?? ""),
                soldCurrency: emptyToNil(cols[safe: 12]),
                soldDate: emptyToNil(cols[safe: 13])
            )
            context.insert(makeItem(from: row))
            count += 1
        }
        try context.save()
        return count
    }

    private static func makeRow(_ item: AssetItem) -> ExportRow {
        ExportRow(
            name: item.name,
            category: item.category.rawValue,
            status: item.status.rawValue,
            tags: item.tagsCSV,
            purchasePrice: item.purchasePrice,
            purchaseCurrency: item.purchaseCurrency,
            purchaseDate: dateFormatter.string(from: item.purchaseDate),
            targetDailyCost: item.targetDailyCost,
            currentValuation: item.currentValuation,
            valuationCurrency: item.valuationCurrency,
            note: item.note,
            soldPrice: item.soldPrice,
            soldCurrency: item.soldCurrency,
            soldDate: item.soldDate.map { dateFormatter.string(from: $0) }
        )
    }

    private static func makeItem(from row: ExportRow) -> AssetItem {
        let item = AssetItem(
            name: row.name,
            category: AssetCategory(rawValue: row.category) ?? .other,
            status: AssetStatus(rawValue: row.status) ?? .inService,
            tags: row.tags.split(separator: ",").map(String.init),
            purchasePrice: row.purchasePrice,
            purchaseCurrency: row.purchaseCurrency,
            purchaseDate: dateFormatter.date(from: row.purchaseDate) ?? Date(),
            targetDailyCost: row.targetDailyCost,
            currentValuation: row.currentValuation,
            valuationCurrency: row.valuationCurrency,
            note: row.note
        )
        item.soldPrice = row.soldPrice
        item.soldCurrency = row.soldCurrency
        if let sold = row.soldDate {
            item.soldDate = dateFormatter.date(from: sold)
        }
        return item
    }

    private static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        var chars = Array(line)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if inQuotes {
                if c == "\"" {
                    if i + 1 < chars.count, chars[i + 1] == "\"" {
                        current.append("\"")
                        i += 1
                    } else {
                        inQuotes = false
                    }
                } else {
                    current.append(c)
                }
            } else if c == "\"" {
                inQuotes = true
            } else if c == "," {
                result.append(current)
                current = ""
            } else {
                current.append(c)
            }
            i += 1
        }
        result.append(current)
        return result
    }

    private static func emptyToNil(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension UTType {
    static var iassetsJSON: UTType {
        UTType(filenameExtension: "json") ?? .json
    }
}
