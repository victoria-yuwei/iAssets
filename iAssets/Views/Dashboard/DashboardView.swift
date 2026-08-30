import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @EnvironmentObject private var settings: AppSettingsStore
    @EnvironmentObject private var rates: ExchangeRateService
    @Query(sort: \AssetItem.updatedAt, order: .reverse) private var items: [AssetItem]
    @Query(sort: \NetWorthSnapshot.day) private var snapshots: [NetWorthSnapshot]
    @Environment(\.modelContext) private var context

    @State private var statusFilter: AssetStatus? = nil

    private var filtered: [AssetItem] {
        guard let statusFilter else { return items }
        return items.filter { $0.status == statusFilter }
    }

    private var netWorth: Double {
        AssetCalculator.netWorth(
            items: items,
            mode: settings.valuationMode,
            base: settings.baseCurrency,
            rates: rates,
            includeSold: settings.includeSoldInNetWorth
        )
    }

    private var byCategory: [(AssetCategory, Double)] {
        AssetCalculator.totalsByCategory(
            items: filtered.filter { settings.includeSoldInNetWorth || $0.status != .sold },
            mode: settings.valuationMode,
            base: settings.baseCurrency,
            rates: rates,
            includeSold: true
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    netWorthCard
                    rateBar
                    statusPicker
                    categorySection
                    trendSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("总览")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await rates.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(rates.isLoading)
                }
            }
            .onAppear { upsertTodaySnapshot() }
            .onChange(of: items.count) { _, _ in upsertTodaySnapshot() }
            .onChange(of: settings.baseCurrency) { _, _ in upsertTodaySnapshot() }
            .onChange(of: rates.lastUpdated) { _, _ in upsertTodaySnapshot() }
        }
    }

    private var netWorthCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("总资产净值")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(CurrencyFormat.string(netWorth, code: settings.baseCurrency))
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text(settings.valuationMode.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 16) {
                metric("全部", items.count)
                metric("服役中", items.filter { $0.status == .inService }.count)
                metric("已退役", items.filter { $0.status == .retired }.count)
                metric("已卖出", items.filter { $0.status == .sold }.count)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.18), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func metric(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.headline)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var rateBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("汇率 · \(settings.baseCurrency)")
                    .font(.subheadline.weight(.medium))
                Text("更新于 \(rates.lastUpdatedText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let err = rates.lastError {
                    Text(err)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
            if rates.isLoading {
                ProgressView()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var statusPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                filterChip("全部", selected: statusFilter == nil) { statusFilter = nil }
                ForEach(AssetStatus.allCases) { status in
                    filterChip(status.title, selected: statusFilter == status) {
                        statusFilter = status
                    }
                }
            }
        }
    }

    private func filterChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(selected ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类结构")
                .font(.headline)
            if byCategory.isEmpty {
                Text("还没有资产，去添加第一件吧。")
                    .foregroundStyle(.secondary)
            } else {
                Chart(byCategory, id: \.0) { item in
                    SectorMark(
                        angle: .value("金额", item.1),
                        innerRadius: .ratio(0.55),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("分类", item.0.title))
                }
                .frame(height: 180)

                ForEach(byCategory, id: \.0) { pair in
                    HStack {
                        Label(pair.0.title, systemImage: pair.0.systemImage)
                        Spacer()
                        Text(CurrencyFormat.compact(pair.1, code: settings.baseCurrency))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("净值趋势")
                .font(.headline)
            let points = snapshots.filter { $0.baseCurrency == settings.baseCurrency }
            if points.count < 2 {
                Text("使用几天后会在这里看到曲线。")
                    .foregroundStyle(.secondary)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value("日期", point.day),
                        y: .value("净值", point.netWorth)
                    )
                    .interpolationMethod(.catmullRom)
                    AreaMark(
                        x: .value("日期", point.day),
                        y: .value("净值", point.netWorth)
                    )
                    .foregroundStyle(Color.accentColor.opacity(0.12))
                }
                .frame(height: 160)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func upsertTodaySnapshot() {
        let today = Calendar.current.startOfDay(for: Date())
        let value = netWorth
        if let existing = snapshots.first(where: {
            Calendar.current.isDate($0.day, inSameDayAs: today) && $0.baseCurrency == settings.baseCurrency
        }) {
            existing.netWorth = value
        } else {
            context.insert(NetWorthSnapshot(day: today, netWorth: value, baseCurrency: settings.baseCurrency))
        }
        try? context.save()
    }
}
