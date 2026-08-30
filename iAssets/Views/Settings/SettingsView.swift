import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var rates: ExchangeRateService
    @EnvironmentObject private var cloud: CloudSyncMonitor
    @Environment(\.modelContext) private var context
    @Query private var items: [AssetItem]

    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var showImporter = false
    @State private var importMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("本位币") {
                    Picker("默认 / 当前本位币", selection: $settings.baseCurrency) {
                        ForEach(SupportedCurrency.allCases) { c in
                            Text(c.title).tag(c.rawValue)
                        }
                    }
                    Text("切换后，总览、日耗、复盘等全部按实时（或缓存）汇率重算。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("汇率") {
                    LabeledContent("上次更新", value: rates.lastUpdatedText)
                    if let err = rates.lastError {
                        Text(err).font(.caption).foregroundStyle(.orange)
                    }
                    Button {
                        Task { await rates.refresh() }
                    } label: {
                        if rates.isLoading {
                            ProgressView()
                        } else {
                            Label("手动刷新汇率", systemImage: "arrow.clockwise")
                        }
                    }
                    Text("策略：每次打开 App 更新一次 + 手动刷新，不做盘中定时轮询。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("iCloud") {
                    Toggle("启用 iCloud 同步", isOn: $settings.iCloudEnabled)
                    LabeledContent("状态", value: cloud.status.title)
                    Text(cloud.status.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("刷新 iCloud 状态") { cloud.refresh() }
                    Text("更改开关后建议重启 App，以便切换本地 / CloudKit 容器。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("总览口径") {
                    Picker("汇总方式", selection: $settings.valuationMode) {
                        ForEach(ValuationMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    Toggle("已卖出计入净值", isOn: $settings.includeSoldInNetWorth)
                }

                Section("数据导入 / 导出") {
                    Button {
                        export(json: true)
                    } label: {
                        Label("导出 JSON 备份", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        export(json: false)
                    } label: {
                        Label("导出 CSV 备份", systemImage: "tablecells")
                    }
                    Button {
                        showImporter = true
                    } label: {
                        Label("从文件导入", systemImage: "square.and.arrow.down")
                    }
                    if let importMessage {
                        Text(importMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ShareLink(
                        item: templateURL(),
                        preview: SharePreview("ImportTemplate.csv")
                    ) {
                        Label("分享 CSV 导入模板", systemImage: "doc.text")
                    }
                }

                Section("关于") {
                    LabeledContent("版本", value: "1.0 MVP")
                    Text("iAssets 免费，面向开源。资产明细不上传到开发者服务器；iCloud 内容归属你的 Apple ID。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("我的")
            .onAppear { cloud.refresh() }
            .sheet(isPresented: $showShare) {
                if let shareURL {
                    ActivityShareView(items: [shareURL])
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json, .commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
        }
    }

    private func export(json: Bool) {
        do {
            let dir = FileManager.default.temporaryDirectory
            if json {
                let data = try ImportExportService.exportJSON(items: items)
                let url = dir.appendingPathComponent("iAssets-backup.json")
                try data.write(to: url, options: .atomic)
                shareURL = url
            } else {
                let csv = ImportExportService.exportCSV(items: items)
                let url = dir.appendingPathComponent("iAssets-backup.csv")
                try Data(csv.utf8).write(to: url, options: .atomic)
                shareURL = url
            }
            showShare = true
        } catch {
            importMessage = "导出失败：\(error.localizedDescription)"
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                importMessage = "无法读取所选文件"
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            let data = try Data(contentsOf: url)
            let count: Int
            if url.pathExtension.lowercased() == "json" {
                count = try ImportExportService.importJSON(data, into: context)
            } else {
                let text = String(decoding: data, as: UTF8.self)
                count = try ImportExportService.importCSV(text, into: context)
            }
            importMessage = "成功导入 \(count) 条资产"
        } catch {
            importMessage = "导入失败：\(error.localizedDescription)"
        }
    }

    private func templateURL() -> URL {
        if let bundled = Bundle.main.url(forResource: "ImportTemplate", withExtension: "csv") {
            return bundled
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ImportTemplate.csv")
        let csv = """
        name,category,status,tags,purchasePrice,purchaseCurrency,purchaseDate,targetDailyCost,currentValuation,valuationCurrency,note,soldPrice,soldCurrency,soldDate
        iPhone 17,digital,inService,手机,7999,CNY,2026-01-15,10,,,日常主力,,,
        """
        try? csv.data(using: .utf8)?.write(to: url)
        return url
    }
}

private struct ActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
