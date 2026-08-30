import Foundation
import Combine
import CloudKit

@MainActor
final class CloudSyncMonitor: ObservableObject {
    static let shared = CloudSyncMonitor()

    enum Status: Equatable {
        case available
        case noAccount
        case restricted
        case couldNotDetermine
        case temporarilyUnavailable
        case disabledInApp

        var title: String {
            switch self {
            case .available: return "iCloud 可用"
            case .noAccount: return "未登录 iCloud"
            case .restricted: return "iCloud 受限"
            case .couldNotDetermine: return "状态未知"
            case .temporarilyUnavailable: return "暂时不可用"
            case .disabledInApp: return "已在 App 内关闭"
            }
        }

        var detail: String {
            switch self {
            case .available:
                return "资产数据将通过你的 Apple ID 同步。"
            case .noAccount:
                return "请在系统设置中登录 iCloud，以便备份与换机恢复。"
            case .restricted:
                return "当前设备限制了 iCloud，仅保存在本机。"
            case .couldNotDetermine, .temporarilyUnavailable:
                return "无法确认 iCloud 状态，请稍后重试。"
            case .disabledInApp:
                return "已关闭同步。数据仅存本机，建议定期导出备份。重启 App 后配置才会切换。"
            }
        }
    }

    @Published private(set) var status: Status = .couldNotDetermine

    func refresh() {
        let settings = AppSettingsStore.shared
        guard settings.iCloudEnabled else {
            status = .disabledInApp
            return
        }

        CKContainer.default().accountStatus { accountStatus, _ in
            Task { @MainActor in
                switch accountStatus {
                case .available:
                    self.status = .available
                case .noAccount:
                    self.status = .noAccount
                case .restricted:
                    self.status = .restricted
                case .couldNotDetermine:
                    self.status = .couldNotDetermine
                case .temporarilyUnavailable:
                    self.status = .temporarilyUnavailable
                @unknown default:
                    self.status = .couldNotDetermine
                }
            }
        }
    }
}
