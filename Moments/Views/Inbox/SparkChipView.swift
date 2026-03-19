import SwiftUI

struct SparkChipView: View {
    let spark: Spark
    let user: MUser?

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(.orange.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(.orange)
                )
                .overlay(
                    Circle()
                        .stroke(.orange, lineWidth: 2)
                        .scaleEffect(1.1)
                )

            Text(user?.displayName ?? "Someone")
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: 64)
    }
}
