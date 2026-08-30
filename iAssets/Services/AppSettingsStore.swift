import Foundation
import Combine

@MainActor
final class AppSettingsStore: ObservableObject {
    static let shared = AppSettingsStore()

    private let defaults = UserDefaults.standard

    @Published var baseCurrency: String {
        didSet { defaults.set(baseCurrency, forKey: Keys.baseCurrency) }
    }

    @Published var valuationMode: ValuationMode {
        didSet { defaults.set(valuationMode.rawValue, forKey: Keys.valuationMode) }
    }

    @Published var iCloudEnabled: Bool {
        didSet { defaults.set(iCloudEnabled, forKey: Keys.iCloudEnabled) }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    @Published var includeSoldInNetWorth: Bool {
        didSet { defaults.set(includeSoldInNetWorth, forKey: Keys.includeSold) }
    }

    private enum Keys {
        static let baseCurrency = "settings.baseCurrency"
        static let valuationMode = "settings.valuationMode"
        static let iCloudEnabled = "settings.iCloudEnabled"
        static let onboarding = "settings.onboardingDone"
        static let includeSold = "settings.includeSold"
    }

    private init() {
        baseCurrency = defaults.string(forKey: Keys.baseCurrency) ?? "CNY"
        let mode = defaults.string(forKey: Keys.valuationMode) ?? ValuationMode.cost.rawValue
        valuationMode = ValuationMode(rawValue: mode) ?? .cost
        // Default ON per product direction for iCloud.
        if defaults.object(forKey: Keys.iCloudEnabled) == nil {
            iCloudEnabled = true
        } else {
            iCloudEnabled = defaults.bool(forKey: Keys.iCloudEnabled)
        }
        hasCompletedOnboarding = defaults.bool(forKey: Keys.onboarding)
        includeSoldInNetWorth = defaults.bool(forKey: Keys.includeSold)
    }
}
