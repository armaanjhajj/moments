import SwiftUI

struct MapGuidedOverlay: View {
    @Binding var isShowing: Bool
    @State private var overlayStep = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { advance() }

                VStack {
                    Spacer()
                    overlayCard
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 24)
            }
            .animation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8), value: overlayStep)
        }
    }

    @ViewBuilder
    private var overlayCard: some View {
        switch overlayStep {
        case 0:
            guidedCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "This is your campus right now",
                body: "Those warm spots? That's where people are.",
                buttonLabel: "Next"
            )
        case 1:
            guidedCard(
                icon: "location.fill",
                iconColor: .blue,
                title: "Your dot is you",
                body: "Move around campus — the map updates live.",
                buttonLabel: "Next"
            )
        case 2:
            guidedCard(
                icon: "mappin.circle.fill",
                iconColor: .accentColor,
                title: "Tap any place to see what's there",
                body: "Places have history. Log yours.",
                buttonLabel: "Got it"
            )
        default:
            EmptyView()
        }
    }

    private func guidedCard(icon: String, iconColor: Color, title: String, body: String, buttonLabel: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(iconColor)

            Text(title)
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(buttonLabel) { advance() }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func advance() {
        if overlayStep < 2 {
            overlayStep += 1
        } else {
            isShowing = false
        }
    }
}
