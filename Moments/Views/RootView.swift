import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var schoolContext: SchoolContext
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var realtimeManager: RealtimeManager

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var onboardingComplete = false

    var body: some View {
        Group {
            if authVM.isLoading {
                splashView
            } else if authVM.needsProfileCreation {
                ProfileCreationView()
            } else if authVM.isSignedIn, authVM.currentUser != nil {
                if hasCompletedOnboarding || onboardingComplete {
                    MapHomeView()
                        .task {
                            if let schoolId = authVM.currentUser?.schoolId {
                                await schoolContext.loadSchool(forId: schoolId)
                            }
                        }
                } else {
                    OnboardingView(isComplete: $onboardingComplete)
                        .onChange(of: onboardingComplete) { _, done in
                            if done { hasCompletedOnboarding = true }
                        }
                }
            } else {
                SignInView()
            }
        }
    }

    private var splashView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)
                Text("Moments")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                ProgressView()
                    .tint(.white)
                    .padding(.top, 8)
            }
        }
    }
}
