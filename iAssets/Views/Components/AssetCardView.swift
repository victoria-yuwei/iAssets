import SwiftUI
import UIKit

struct AssetCardView: View {
    let item: AssetItem
    let baseCurrency: String
    let mode: ValuationMode
    let rates: ExchangeRateService
    var isGrid: Bool = true

    private var value: Double {
        AssetCalculator.displayValue(item, mode: mode, base: baseCurrency, rates: rates)
    }

    private var daily: Double {
        AssetCalculator.dailyCost(item, base: baseCurrency, rates: rates)
    }

    var body: some View {
        Group {
            if isGrid {
                gridBody
            } else {
                listBody
            }
        }
    }

    private var gridBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageBlock
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(item.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)

            Text(CurrencyFormat.compact(value, code: baseCurrency))
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                StatusChip(status: item.status)
                Spacer()
                Text("日耗 \(CurrencyFormat.compact(daily, code: baseCurrency))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var listBody: some View {
        HStack(spacing: 12) {
            imageBlock
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text("\(item.category.title) · \(CurrencyFormat.compact(value, code: baseCurrency))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusChip(status: item.status)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var imageBlock: some View {
        if let data = item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.25), Color.accentColor.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: item.category.systemImage)
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}
