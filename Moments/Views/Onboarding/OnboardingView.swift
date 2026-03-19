import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var schoolContext: SchoolContext
    @EnvironmentObject private var locationManager: LocationManager

    @State private var currentStep = 0
    @Binding var isComplete: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentStep) {
                // Step 0: Splash
                splashStep.tag(0)

                // Step 1: Location permission pre-warm
                locationStep.tag(1)

                // Step 2: Map reveal with guided overlay
                mapRevealStep.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentStep)
        }
    }

    // MARK: - Splash

    private var splashStep: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "map.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)

            Text("Moments")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Your campus, for real.")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            Button {
                withAnimation { currentStep = 1 }
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Location Permission

    private var locationStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .padding()
                .background(.blue.opacity(0.15), in: Circle())

            Text("Moments works because it knows where you are on campus.")
                .font(.title3.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                locationBullet(icon: "mappin.circle.fill", text: "See what's happening nearby")
                locationBullet(icon: "person.2.fill", text: "Find people whose paths cross yours")
                locationBullet(icon: "map.fill", text: "Build your campus map over time")
            }
            .padding(.horizontal, 8)

            Text("We never share your precise location. You're always snapped to the nearest named place — not a GPS pin.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    locationManager.requestWhenInUse()
                    withAnimation { currentStep = 2 }
                } label: {
                    Text("Allow Location")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    withAnimation { currentStep = 2 }
                } label: {
                    Text("Set up manually")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding(.horizontal)
    }

    private func locationBullet(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    // MARK: - Map Reveal

    private var mapRevealStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Your campus is alive")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Warm spots show where people are right now. Tap any place to see what's happening there.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Spacer()

            Button {
                isComplete = true
            } label: {
                Text("Enter the Map")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}
