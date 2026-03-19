import SwiftUI

struct SparkCardView: View {
    let spark: Spark
    @ObservedObject var viewModel: InboxViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isActing = false
    @State private var cardScale: CGFloat = 0.85
    @State private var cardOpacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var otherUserId: UUID {
        // Determine which user is the "other" one
        spark.userA // simplified — in real usage compare with current user
    }

    var body: some View {
        VStack(spacing: 20) {
            // Avatar
            Circle()
                .fill(.orange.opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                )

            // Name
            if let user = viewModel.sparkUsers[spark.userA] ?? viewModel.sparkUsers[spark.userB] {
                Text(user.displayName)
                    .font(.title3.bold())
                Text("@\(user.handle)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Overlap context
            VStack(spacing: 4) {
                if let placeName = spark.overlapContext.placeName {
                    Label(placeName, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                }
                if let count = spark.overlapContext.visitCount, count > 0 {
                    Text("You've both been here \(count) times")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let interest = spark.overlapContext.sharedInterest {
                    Text("Shared interest: \(interest)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // Actions
            HStack(spacing: 16) {
                Button {
                    Task {
                        isActing = true
                        await viewModel.dismissSpark(spark)
                        isActing = false
                        dismiss()
                    }
                } label: {
                    Text("Not now")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(isActing)

                Button {
                    Task {
                        isActing = true
                        _ = await viewModel.sayHi(to: spark)
                        isActing = false
                        dismiss()
                    }
                } label: {
                    Text("Say hi")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isActing)
            }
        }
        .padding(24)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .onAppear {
            let animation: Animation = reduceMotion
                ? .easeOut(duration: 0.2)
                : .spring(response: 0.5, dampingFraction: 0.7)
            withAnimation(animation) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
        }
    }
}
