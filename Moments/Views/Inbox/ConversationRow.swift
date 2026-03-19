import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation
    let otherUser: MUser?
    let lastMessage: Message?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.quaternary)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(otherUser?.displayName ?? "Unknown")
                    .font(.subheadline.bold())

                if let msg = lastMessage {
                    Text(msg.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let msg = lastMessage, let date = msg.createdAt {
                Text(date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            // Spark context badge
            if conversation.sparkContext != nil {
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
