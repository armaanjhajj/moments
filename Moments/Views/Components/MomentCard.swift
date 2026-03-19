import SwiftUI

struct MomentCard: View {
    let moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(.quaternary)
                    .frame(width: 28, height: 28)
                    .overlay(Image(systemName: "person.fill").font(.caption2).foregroundStyle(.secondary))

                VStack(alignment: .leading) {
                    Text(contentTypeLabel)
                        .font(.caption.bold())
                    if let date = moment.createdAt {
                        Text(date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                Image(systemName: contentTypeIcon)
                    .foregroundStyle(.secondary)
            }

            // Content preview
            Group {
                switch moment.contentType {
                case .text:
                    if let text = moment.textContent {
                        Text(text)
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                case .photo, .video:
                    if let url = moment.contentUrl {
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(.quaternary)
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                case .song:
                    HStack {
                        if let artUrl = moment.songArtUrl, let url = URL(string: artUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(.quaternary)
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        VStack(alignment: .leading) {
                            Text(moment.songTitle ?? "Unknown Song")
                                .font(.subheadline.bold())
                            Text(moment.songArtist ?? "Unknown Artist")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                case .voice:
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundStyle(Color.accentColor)
                        Text("Voice memo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var contentTypeIcon: String {
        switch moment.contentType {
        case .photo: return "photo"
        case .video: return "video"
        case .text: return "text.quote"
        case .song: return "music.note"
        case .voice: return "waveform"
        }
    }

    private var contentTypeLabel: String {
        switch moment.contentType {
        case .photo: return "Photo"
        case .video: return "Video"
        case .text: return "Text"
        case .song: return "Song"
        case .voice: return "Voice"
        }
    }
}
