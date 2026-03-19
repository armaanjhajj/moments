import SwiftUI

struct SpatialFeedView: View {
    @EnvironmentObject private var schoolContext: SchoolContext
    @StateObject private var viewModel = SpatialFeedViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Feed", selection: $viewModel.selectedMode) {
                    ForEach(SpatialFeedViewModel.FeedMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    feedContent
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            guard let schoolId = schoolContext.schoolId else { return }
            await viewModel.loadFeed(schoolId: schoolId)
        }
    }

    @ViewBuilder
    private var feedContent: some View {
        let moments = viewModel.selectedMode == .history ? viewModel.myHistory : viewModel.campusFeed

        if moments.isEmpty {
            ContentUnavailableView(
                viewModel.selectedMode == .history
                    ? "No moments yet"
                    : "Connect with people to see their moments",
                systemImage: viewModel.selectedMode == .history ? "clock" : "person.2",
                description: Text(viewModel.selectedMode == .history
                    ? "Post your first moment at a campus place."
                    : "Your campus feed shows content from connections and places you visit.")
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(moments) { moment in
                        MomentCard(moment: moment)
                    }
                }
                .padding()
            }
        }
    }
}
