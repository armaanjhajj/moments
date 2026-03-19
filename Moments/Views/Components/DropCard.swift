import SwiftUI

struct DropCard: View {
    let drop: Drop

    var body: some View {
        HStack {
            Circle()
                .fill(glowColor.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .fill(glowColor)
                        .frame(width: 16, height: 16)
                )

            VStack(alignment: .leading, spacing: 2) {
                if let hint = drop.hint, !hint.isEmpty {
                    Text(hint)
                        .font(.subheadline)
                        .lineLimit(1)
                } else {
                    Text("Mystery Drop")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Text(drop.visibility.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    if let expires = drop.expiresAt {
                        Text("expires \(expires, style: .relative)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }

    private var glowColor: Color {
        .orange // enriched when content_type loaded
    }
}
