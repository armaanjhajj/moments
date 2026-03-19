import SwiftUI

struct PlaceProfileView: View {
    let place: Place

    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = PlaceProfileViewModel()
    @State private var selectedTab = 0
    @State private var showLogSheet = false
    @State private var showDropSheet = false

    private var isNearby: Bool {
        guard let distance = locationManager.distanceToPlace(place) else { return false }
        return distance <= 100
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                tabPicker

                TabView(selection: $selectedTab) {
                    nowTab.tag(0)
                    historyTab.tag(1)
                    connectionsTab.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                actionBar
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadAll(place: place)
        }
        .sheet(isPresented: $showLogSheet) {
            PlaceLogSheet(place: place, viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showDropSheet) {
            CreateMomentView(presetPlace: place)
                .presentationDetents([.large])
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: iconForType(place.type))
                    .foregroundStyle(colorForType(place.type))
                Text(place.name)
                    .font(.title3.bold())
                Spacer()
                if viewModel.averageRating > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", viewModel.averageRating))
                            .font(.subheadline.bold())
                    }
                }
            }

            HStack {
                Label(place.type.rawValue.capitalized, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let count = viewModel.recentMoments.count as Int?, count > 0 {
                    Text("\(count) posts today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            Text("Now").tag(0)
            Text("History").tag(1)
            Text("Connections").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - Now Tab

    private var nowTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.rooms.isEmpty {
                    ForEach(viewModel.rooms) { room in
                        RoomBannerCard(room: room)
                    }
                }

                if !viewModel.activeDrops.isEmpty {
                    Text("Active Drops")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(viewModel.activeDrops) { drop in
                        DropCard(drop: drop)
                            .padding(.horizontal)
                    }
                }

                if !viewModel.recentMoments.isEmpty {
                    Text("Recent")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(viewModel.recentMoments) { moment in
                        MomentCard(moment: moment)
                            .padding(.horizontal)
                    }
                }

                if viewModel.recentMoments.isEmpty && viewModel.activeDrops.isEmpty {
                    ContentUnavailableView("Nothing happening right now", systemImage: "wind", description: Text("Be the first to post or drop something here."))
                        .padding(.top, 40)
                }
            }
            .padding(.top, 12)
        }
    }

    // MARK: - History Tab

    private var historyTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                // Aggregate stats
                if viewModel.averageRating > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Community Rating")
                            .font(.headline)

                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: Double(star) <= viewModel.averageRating ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                            }
                            Text(String(format: "%.1f", viewModel.averageRating))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("(\(viewModel.placeLogs.count) logs)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.horizontal)
                }

                // Mood distribution
                if !viewModel.moodDistribution.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vibes")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(Array(viewModel.moodDistribution.sorted { $0.value > $1.value }), id: \.key) { mood, count in
                                Text("\(moodEmoji(mood)) \(mood.replacingOccurrences(of: "_", with: " ")) (\(count))")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(.quaternary, in: Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Regulars
                if !viewModel.regulars.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Regulars")
                            .font(.headline)
                        ForEach(viewModel.regulars, id: \.userId) { regular in
                            HStack {
                                Circle()
                                    .fill(.quaternary)
                                    .frame(width: 28, height: 28)
                                    .overlay(Image(systemName: "person.fill").font(.caption).foregroundStyle(.secondary))
                                Text("\(regular.count) visits")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Log history
                if !viewModel.placeLogs.isEmpty {
                    Text("Log History")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(viewModel.placeLogs) { log in
                        PlaceLogRow(log: log)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Connections Tab

    private var connectionsTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.overlapEvents.isEmpty {
                    Text("You've been here with")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(viewModel.overlapEvents) { event in
                        HStack {
                            Circle()
                                .fill(.quaternary)
                                .frame(width: 32, height: 32)
                                .overlay(Image(systemName: "person.2.fill").font(.caption2).foregroundStyle(.secondary))
                            Text("Co-visit")
                                .font(.subheadline)
                            Spacer()
                            if let date = event.occurredAt {
                                Text(date, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ContentUnavailableView("No overlap history yet", systemImage: "person.2", description: Text("Visit this place and you'll see who you keep running into."))
                        .padding(.top, 40)
                }

                if !viewModel.rooms.isEmpty {
                    Text("Rooms at this place")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(viewModel.rooms) { room in
                        RoomBannerCard(room: room)
                    }
                }
            }
            .padding(.top, 12)
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                showLogSheet = true
            } label: {
                Label(isNearby ? "Log this place" : "Get closer to log", systemImage: "square.and.pencil")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isNearby)

            Button {
                showDropSheet = true
            } label: {
                Label("Drop", systemImage: "arrow.down.circle.fill")
                    .font(.subheadline.bold())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.bordered)
            .disabled(!isNearby)
        }
        .padding()
    }

    // MARK: - Helpers

    private func iconForType(_ type: PlaceType) -> String {
        switch type {
        case .library: return "books.vertical.fill"
        case .dining: return "fork.knife"
        case .gym: return "figure.run"
        case .outdoor: return "leaf.fill"
        case .building: return "building.2.fill"
        case .dorm: return "house.fill"
        }
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

    private func moodEmoji(_ mood: String) -> String {
        switch mood {
        case "buzzing": return "⚡"
        case "chill": return "😌"
        case "productive": return "💻"
        case "party": return "🎉"
        case "reflective": return "🌙"
        case "good_vibes": return "✨"
        default: return "📍"
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
