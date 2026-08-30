import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var cloud: CloudSyncMonitor

    @State private var step = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $step) {
                introPage.tag(0)
                currencyPage.tag(1)
                icloudPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: primaryAction) {
                Text(step < 2 ? "继续" : "开始使用")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .background(Color(.systemBackground))
    }

    private var introPage: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text("万物资产化")
                .font(.largeTitle.bold())
            Text("把数码、硬通货、非标品与虚拟权益放进陈列柜，算清日耗与变现盈亏。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var currencyPage: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("选择本位币")
                .font(.title.bold())
            Text("默认人民币。之后可随时更改；更改后全库按实时汇率换算。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Picker("本位币", selection: $settings.baseCurrency) {
                ForEach(SupportedCurrency.allCases) { c in
                    Text(c.title).tag(c.rawValue)
                }
            }
            .pickerStyle(.wheel)
            Spacer()
        }
    }

    private var icloudPage: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "icloud.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
            Text("iCloud 同步")
                .font(.title.bold())
            Text("资产数据可写入你自己的 iCloud（Apple ID），无 App 自建账号。网络还会用于拉取实时汇率。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Toggle("启用 iCloud", isOn: $settings.iCloudEnabled)
                .padding(.horizontal, 40)
            Text(cloud.status.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
                .onAppear { cloud.refresh() }
            Spacer()
        }
    }

    private func primaryAction() {
        if step < 2 {
            withAnimation { step += 1 }
            if step == 2 { cloud.refresh() }
        } else {
            settings.hasCompletedOnboarding = true
        }
    }
}
