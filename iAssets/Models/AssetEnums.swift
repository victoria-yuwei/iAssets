import Foundation

enum AssetStatus: String, Codable, CaseIterable, Identifiable {
    case inService
    case retired
    case sold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inService: return "服役中"
        case .retired: return "已退役"
        case .sold: return "已卖出"
        }
    }
}

enum AssetCategory: String, Codable, CaseIterable, Identifiable {
    case digital
    case hardCurrency
    case collectible
    case virtual
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .digital: return "数码"
        case .hardCurrency: return "硬通货"
        case .collectible: return "非标品"
        case .virtual: return "虚拟权益"
        case .other: return "其他"
        }
    }

    var systemImage: String {
        switch self {
        case .digital: return "laptopcomputer"
        case .hardCurrency: return "bitcoinsign.circle"
        case .collectible: return "shippingbox"
        case .virtual: return "gamecontroller"
        case .other: return "tag"
        }
    }
}

enum ValuationMode: String, Codable, CaseIterable, Identifiable {
    case cost
    case valuation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cost: return "按购入成本"
        case .valuation: return "按当前估值"
        }
    }
}

enum SupportedCurrency: String, CaseIterable, Identifiable {
    case CNY, USD, EUR, JPY, GBP, HKD, TWD, SGD, AUD, CAD, CHF, KRW

    var id: String { rawValue }

    var title: String {
        switch self {
        case .CNY: return "人民币 CNY"
        case .USD: return "美元 USD"
        case .EUR: return "欧元 EUR"
        case .JPY: return "日元 JPY"
        case .GBP: return "英镑 GBP"
        case .HKD: return "港币 HKD"
        case .TWD: return "新台币 TWD"
        case .SGD: return "新加坡元 SGD"
        case .AUD: return "澳元 AUD"
        case .CAD: return "加元 CAD"
        case .CHF: return "瑞士法郎 CHF"
        case .KRW: return "韩元 KRW"
        }
    }
}
