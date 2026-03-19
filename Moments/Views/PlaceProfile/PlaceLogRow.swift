import SwiftUI

struct PlaceLogRow: View {
    let log: PlaceLog

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: Double(star) <= log.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                    }
                    Text(moodLabel(log.mood))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
                if let note = log.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
            if let date = log.createdAt {
                Text(date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private func moodLabel(_ mood: PlaceMood) -> String {
        switch mood {
        case .buzzing: return "⚡ Buzzing"
        case .chill: return "😌 Chill"
        case .productive: return "💻 Productive"
        case .party: return "🎉 Party"
        case .reflective: return "🌙 Reflective"
        case .goodVibes: return "✨ Good Vibes"
        }
    }
}
