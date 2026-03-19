import SwiftUI
import MapKit

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var schoolContext: SchoolContext
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                profileHeader
                tabPicker

                TabView(selection: $selectedTab) {
                    mapTab.tag(0)
                    postsTab.tag(1)
                    dropsTab.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Sign Out", role: .destructive) {
                            Task { await authVM.signOut() }
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .task {
            guard let user = authVM.currentUser,
                  let schoolId = schoolContext.schoolId else { return }
            await viewModel.loadProfile(userId: user.id, schoolId: schoolId)
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(.quaternary)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                )

            if let user = authVM.currentUser {
                Text(user.displayName)
                    .font(.title3.bold())
                Text("@\(user.handle)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Stats row — no follower counts, just connections and places
                HStack(spacing: 24) {
                    statItem(count: viewModel.connectionCount, label: "Connections")
                    statItem(count: viewModel.visitCounts.count, label: "Places")
                    statItem(count: viewModel.moments.count, label: "Moments")
                }
                .padding(.top, 4)
            }
        }
        .padding()
    }

    private func statItem(count: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.subheadline.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            Text("Map").tag(0)
            Text("Posts").tag(1)
            Text("Drops").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - Map Tab (Visit Heat Map)

    private var mapTab: some View {
        Map {
            // Heat map visualization — show circles at visited places
            ForEach(Array(viewModel.visitCounts), id: \.key) { placeId, count in
                if let place = viewModel.visitedPlaces.first(where: { $0.id == placeId }) {
                    MapCircle(
                        center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                        radius: CLLocationDistance(max(count * 20, 30))
                    )
                    .foregroundStyle(.orange.opacity(min(Double(count) * 0.1, 0.6)))
                    .stroke(.orange.opacity(0.4), lineWidth: 1)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
    }

    // MARK: - Posts Tab (grouped by place)

    private var postsTab: some View {
        ScrollView {
            if viewModel.moments.isEmpty {
                ContentUnavailableView("No moments yet", systemImage: "camera", description: Text("Post your first moment at a place."))
                    .padding(.top, 40)
            } else {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.momentsByPlace, id: \.placeId) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Label("\(group.moments.count) posts", systemImage: "mappin")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            ForEach(group.moments) { moment in
                                MomentCard(moment: moment)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Drops Tab

    private var dropsTab: some View {
        ScrollView {
            if viewModel.activeDrops.isEmpty {
                ContentUnavailableView("No drops yet", systemImage: "arrow.down.circle", description: Text("Leave your first Drop at a place."))
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.activeDrops) { drop in
                        DropCard(drop: drop)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 12)
            }
        }
    }
}
