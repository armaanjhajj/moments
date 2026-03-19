import SwiftUI

struct DropPinView: View {
    let drop: Drop

    @State private var glowScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .fill(glowColor.opacity(0.6))
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .fill(glowColor)
                    .frame(width: 12, height: 12)
            )
            .overlay(
                Circle()
                    .stroke(glowColor.opacity(0.3), lineWidth: 2)
                    .scaleEffect(glowScale)
            )
            .shadow(color: glowColor.opacity(0.4), radius: 6)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowScale = 1.4
                }
            }
            .accessibilityLabel("Drop pin for \(drop.hint ?? "a hidden drop")")
    }

    private var glowColor: Color {
        // Default to orange; enriched when moment content_type is loaded
        .orange
    }
}
