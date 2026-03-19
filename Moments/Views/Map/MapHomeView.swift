import SwiftUI
import MapKit

struct MapHomeView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var schoolContext: SchoolContext
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var realtimeManager: RealtimeManager

    @StateObject private var viewModel = MapHomeViewModel()
    @State private var showPlaceProfile = false
    @State private var showCreateSheet = false
    @State private var showKimba = false
    @State private var selectedTab: TabItem = .map
    @State private var showFeed = false
    @State private var showInbox = false
    @State private var showProfile = false
    @State private var showGuidedOverlay = false
    @State private var showFirstLogPrompt = false
    @State private var showPlaceLogFromPrompt = false
    @AppStorage("hasSeenMapGuide") private var hasSeenMapGuide = false
    @StateObject private var placeProfileVM = PlaceProfileViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main map
            mapLayer

            // Top bar
            VStack {
                topBar
                Spacer()
            }

            // First-log prompt
            if showFirstLogPrompt, let place = locationManager.currentPlace {
                VStack {
                    Spacer()
                    FirstLogPrompt(
                        placeName: place.name,
                        onLog: {
                            viewModel.selectedPlace = place
                            showFirstLogPrompt = false
                            showPlaceLogFromPrompt = true
                        },
                        onDismiss: { showFirstLogPrompt = false }
                    )
                    .padding(.bottom, 80)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Bottom tab bar
            tabBar

            // Guided overlay for first-time users
            MapGuidedOverlay(isShowing: $showGuidedOverlay)
        }
        .fullScreenCover(isPresented: $showInbox) {
            InboxView()
                .environmentObject(schoolContext)
                .environmentObject(realtimeManager)
        }
        .fullScreenCover(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authVM)
                .environmentObject(schoolContext)
        }
        .sheet(isPresented: $showPlaceProfile) {
            if let place = viewModel.selectedPlace {
                PlaceProfileView(place: place)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateMomentView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showKimba) {
            KimbaView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showFeed) {
            SpatialFeedView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPlaceLogFromPrompt) {
            if let place = viewModel.selectedPlace {
                PlaceLogSheet(place: place, viewModel: placeProfileVM)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .task {
            guard let schoolId = schoolContext.schoolId else { return }
            await viewModel.loadMapData(
                schoolId: schoolId,
                campusCenter: schoolContext.campusCenter
            )
            locationManager.setPlaces(viewModel.places)
            locationManager.setSchoolId(schoolId)
            locationManager.configure()
            locationManager.requestWhenInUse()
            locationManager.startPinging()
            await realtimeManager.subscribeToPresence(schoolId: schoolId)
            await realtimeManager.refreshPresenceCounts(schoolId: schoolId)

            // Show guided overlay for first-time users
            if !hasSeenMapGuide {
                try? await Task.sleep(for: .seconds(1))
                showGuidedOverlay = true
                hasSeenMapGuide = true

                // Show first-log prompt after overlay dismisses
                try? await Task.sleep(for: .seconds(5))
                if locationManager.currentPlace != nil {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showFirstLogPrompt = true
                    }
                }
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map(position: $viewModel.cameraPosition) {
            // User location
            UserAnnotation()

            // Place pins
            ForEach(viewModel.places) { place in
                Annotation(place.name, coordinate: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                )) {
                    PlacePinView(
                        place: place,
                        icon: viewModel.placeIcon(for: place.type),
                        activeCount: realtimeManager.presenceCounts[place.id] ?? 0
                    )
                    .onTapGesture {
                        viewModel.selectedPlace = place
                        showPlaceProfile = true
                    }
                }
            }

            // Drop pins
            ForEach(viewModel.drops) { drop in
                Annotation("", coordinate: CLLocationCoordinate2D(
                    latitude: drop.latitude,
                    longitude: drop.longitude
                )) {
                    DropPinView(drop: drop)
                }
            }

            // Density overlays
            ForEach(Array(realtimeManager.presenceCounts.filter { $0.value >= 3 }), id: \.key) { placeId, count in
                if let place = viewModel.places.first(where: { $0.id == placeId }) {
                    MapCircle(
                        center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                        radius: CLLocationDistance(min(count * 15, 100))
                    )
                    .foregroundStyle(.orange.opacity(0.15))
                    .stroke(.orange.opacity(0.3), lineWidth: 1)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .ignoresSafeArea(edges: .top)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height < -100 {
                        showFeed = true
                    }
                }
        )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Ghost mode toggle
            Button {
                locationManager.toggleGhostMode()
            } label: {
                Image(systemName: locationManager.ghostModeActive ? "eye.slash.fill" : "eye.fill")
                    .font(.title3)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Spacer()

            // Kimba AI button
            Button {
                showKimba = true
            } label: {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 50)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(.map, icon: "map.fill")
            tabButton(.inbox, icon: "bubble.left.and.bubble.right.fill")
            cameraButton
            tabButton(.profile, icon: "person.fill")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func tabButton(_ tab: TabItem, icon: String) -> some View {
        Button {
            switch tab {
            case .map: break
            case .inbox: showInbox = true
            case .profile: showProfile = true
            }
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }

    private var cameraButton: some View {
        Button {
            showCreateSheet = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }
}

enum TabItem {
    case map, inbox, profile
}
