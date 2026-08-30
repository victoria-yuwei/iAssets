import Foundation
import SwiftData

@Model
final class NetWorthSnapshot {
    var id: UUID
    var day: Date
    var netWorth: Double
    var baseCurrency: String

    init(day: Date, netWorth: Double, baseCurrency: String) {
        self.id = UUID()
        self.day = Calendar.current.startOfDay(for: day)
        self.netWorth = netWorth
        self.baseCurrency = baseCurrency
    }
}

extension NetWorthSnapshot: Identifiable {}
