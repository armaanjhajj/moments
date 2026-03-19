import SwiftUI

struct DropUnlockView: View {
    let drop: Drop
    let moment: Moment?
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var showContent = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                if showContent, let moment {
                    // Revealed content
                    VStack(spacing: 12) {
                        contentView(for: moment)

                        if let hint = drop.hint, !hint.isEmpty {
                            Text(hint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Post-unlock actions
                        HStack(spacing: 16) {
                            reactionButton("😊")
                            reactionButton("🔥")
                            reactionButton("💜")
                            reactionButton("😂")
                            reactionButton("🤯")

                            Button {
                                // reply action — opens DM
                            } label: {
                                Image(systemName: "bubble.right")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Bloom animation
                    Circle()
                        .fill(.orange.gradient)
                        .frame(width: 120, height: 120)
                        .scaleEffect(scale)
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            if reduceMotion {
                scale = 1.0
                opacity = 1.0
                showContent = true
            } else {
                // Bloom animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                // Show content after bloom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showContent = true
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func contentView(for moment: Moment) -> some View {
        switch moment.contentType {
        case .text:
            Text(moment.textContent ?? "")
                .font(.body)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

        case .photo, .video:
            if let url = moment.contentUrl, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

        case .song:
            VStack {
                Image(systemName: "music.note")
                    .font(.largeTitle)
                    .foregroundStyle(.purple)
                Text(moment.songTitle ?? "Unknown")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(moment.songArtist ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

        case .voice:
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.green)
                Text("Voice memo")
                    .foregroundStyle(.white)
            }
        }
    }

    private func reactionButton(_ emoji: String) -> some View {
        Button {
            // Send reaction
        } label: {
            Text(emoji)
                .font(.title2)
        }
    }
}
