import SwiftUI
import SwiftData
import UIKit

struct AssetDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var rates: ExchangeRateService

    @Bindable var item: AssetItem
    @State private var showSell = false
    @State private var showDeleteConfirm = false

    private var purchaseBase: Double {
        AssetCalculator.purchaseInBase(item, base: settings.baseCurrency, rates: rates)
    }

    private var daily: Double {
        AssetCalculator.dailyCost(item, base: settings.baseCurrency, rates: rates)
    }

    private var paidBack: Bool? {
        AssetCalculator.isPaidBack(item, base: settings.baseCurrency, rates: rates)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                header
                costSection
                progressSection
                metaSection
                actions
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSell) {
            NavigationStack {
                SellAssetView(item: item)
            }
        }
        .confirmationDialog("删除这件资产？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                context.delete(item)
                try? context.save()
                dismiss()
            }
        }
    }

    private var hero: some View {
        Group {
            if let data = item.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: item.category.systemImage)
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                StatusChip(status: item.status)
                Text(item.category.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if !item.tags.isEmpty {
                Text(item.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var costSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            row("购入价", "\(CurrencyFormat.string(item.purchasePrice, code: item.purchaseCurrency))")
            row("折合 \(settings.baseCurrency)", CurrencyFormat.string(purchaseBase, code: settings.baseCurrency))
            row("持有天数", "\(item.holdingDays) 天")
            row("日均成本", CurrencyFormat.string(daily, code: settings.baseCurrency))
            if let target = item.targetDailyCost {
                row("目标日耗", CurrencyFormat.string(target, code: settings.baseCurrency))
                if let paidBack {
                    row("回本状态", paidBack ? "已达成" : "未达成")
                }
            }
            if let pl = AssetCalculator.profitLoss(item, base: settings.baseCurrency, rates: rates) {
                row("变现盈亏", CurrencyFormat.string(pl, code: settings.baseCurrency))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("服役进度（按约 3 年参考）")
                .font(.subheadline.weight(.medium))
            ProgressView(value: AssetCalculator.serviceProgress(purchaseDate: item.purchaseDate))
                .tint(.accentColor)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            row("购入日", item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
            if let valuation = item.currentValuation {
                let code = item.valuationCurrency ?? item.purchaseCurrency
                row("当前估值", CurrencyFormat.string(valuation, code: code))
            }
            if !item.note.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("备注")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.note)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var actions: some View {
        VStack(spacing: 10) {
            if item.status != .sold {
                Button {
                    item.status = .retired
                    item.updatedAt = .now
                    try? context.save()
                } label: {
                    Label("标记为已退役", systemImage: "archivebox")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    showSell = true
                } label: {
                    Label("登记变现", systemImage: "yensign.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if item.status == .retired {
                Button {
                    item.status = .inService
                    item.updatedAt = .now
                    try? context.save()
                } label: {
                    Label("恢复服役", systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("删除", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
