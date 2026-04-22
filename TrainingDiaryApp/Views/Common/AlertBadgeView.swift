import SwiftUI

struct AlertBadgeView: View {
    let level: AlertLevel

    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var label: String {
        switch level {
        case .normal: return "通常"
        case .caution: return "注意"
        case .warning: return "警告"
        }
    }

    private var color: Color {
        switch level {
        case .normal: return .green
        case .caution: return .orange
        case .warning: return .red
        }
    }
}
