import SwiftUI

struct PlacePinView: View {
    let place: Place
    let icon: String
    let activeCount: Int

    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(colorForType(place.type), in: Circle())
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.orange, in: Capsule())
                        .offset(x: 6, y: -4)
                }
            }

            Text(place.name)
                .font(.system(size: 9, weight: .medium))
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(place.name), \(place.type.rawValue)\(activeCount > 0 ? ", \(activeCount) people here" : "")")
    }

    private func colorForType(_ type: PlaceType) -> Color {
        switch type {
        case .library: return .blue
        case .dining: return .orange
        case .gym: return .green
        case .outdoor: return .mint
        case .building: return .purple
        case .dorm: return .indigo
        }
    }
}
