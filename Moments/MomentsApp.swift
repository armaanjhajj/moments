import SwiftUI

@main
struct MomentsApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var schoolContext = SchoolContext()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var realtimeManager = RealtimeManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(schoolContext)
                .environmentObject(locationManager)
                .environmentObject(realtimeManager)
                .task {
                    await authVM.restoreSession()
                }
        }
    }
}
