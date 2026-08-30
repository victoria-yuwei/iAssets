import SwiftUI

struct StatusChip: View {
    let status: AssetStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch status {
        case .inService: return .white
        case .retired: return .primary
        case .sold: return .white
        }
    }

    private var background: Color {
        switch status {
        case .inService: return Color.accentColor
        case .retired: return Color.secondary.opacity(0.2)
        case .sold: return Color.orange
        }
    }
}
