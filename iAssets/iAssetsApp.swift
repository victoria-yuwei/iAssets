import SwiftUI
import SwiftData

@main
struct iAssetsApp: App {
    @StateObject private var settings = AppSettingsStore.shared
    @StateObject private var rates = ExchangeRateService.shared
    @StateObject private var cloud = CloudSyncMonitor.shared

    private let container: ModelContainer

    init() {
        container = Self.makeContainer(iCloudEnabled: AppSettingsStore.shared.iCloudEnabled)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(rates)
                .environmentObject(cloud)
                .task {
                    await rates.refreshIfNeeded(force: false)
                    cloud.refresh()
                }
        }
        .modelContainer(container)
    }

    private static func makeContainer(iCloudEnabled: Bool) -> ModelContainer {
        let schema = Schema([AssetItem.self, NetWorthSnapshot.self])
        let cloudKit: ModelConfiguration.CloudKitDatabase = iCloudEnabled
            ? .automatic
            : .none
        let configuration = ModelConfiguration(
            "iAssets",
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKit
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Fallback to local-only if CloudKit setup fails (e.g. simulator / no capability).
            let local = ModelConfiguration(
                "iAssetsLocal",
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            return try! ModelContainer(for: schema, configurations: [local])
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var settings: AppSettingsStore

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}
