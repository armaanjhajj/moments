import SwiftUI

struct InboxView: View {
    @EnvironmentObject private var schoolContext: SchoolContext
    @StateObject private var viewModel = InboxViewModel()
    @State private var selectedTab = 0
    @State private var selectedConversation: Conversation?
    @State private var selectedSpark: Spark?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Messages").tag(0)
                    Text("Rooms").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    messagesTab
                } else {
                    roomsTab
                }
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            guard let schoolId = schoolContext.schoolId else { return }
            await viewModel.loadInbox(schoolId: schoolId)
        }
        .sheet(item: $selectedConversation) { conv in
            ChatView(conversation: conv)
                .presentationDetents([.large])
        }
        .sheet(item: $selectedSpark) { spark in
            SparkCardView(spark: spark, viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Messages Tab

    private var messagesTab: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Spark bar
                if !viewModel.sparks.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.sparks) { spark in
                                SparkChipView(
                                    spark: spark,
                                    user: viewModel.sparkUsers[spark.userA] ?? viewModel.sparkUsers[spark.userB]
                                )
                                .onTapGesture { selectedSpark = spark }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)

                    Divider()
                }

                // Conversations
                if viewModel.conversations.isEmpty {
                    ContentUnavailableView("No messages yet", systemImage: "bubble.left", description: Text("Start a conversation from a Spark or Room."))
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.conversations) { conv in
                        ConversationRow(
                            conversation: conv,
                            otherUser: viewModel.conversationUsers[conv.userA] ?? viewModel.conversationUsers[conv.userB],
                            lastMessage: viewModel.lastMessages[conv.id]
                        )
                        .onTapGesture { selectedConversation = conv }

                        Divider().padding(.leading, 60)
                    }
                }
            }
        }
    }

    // MARK: - Rooms Tab

    private var roomsTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if !viewModel.rooms.isEmpty {
                    Text("Your Rooms")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ForEach(viewModel.rooms) { room in
                        RoomBannerCard(room: room)
                    }
                }

                Text("Discover")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ForEach(viewModel.allRooms.filter { room in
                    !viewModel.rooms.contains(where: { $0.id == room.id })
                }) { room in
                    RoomBannerCard(room: room)
                }

                if viewModel.allRooms.isEmpty {
                    ContentUnavailableView("No rooms yet", systemImage: "bubble.left.and.bubble.right", description: Text("Rooms will appear here as they're created."))
                        .padding(.top, 40)
                }
            }
            .padding(.top, 12)
        }
    }
}

// Make Conversation conform to Identifiable for sheet binding
extension Conversation: Hashable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Spark: Hashable {
    static func == (lhs: Spark, rhs: Spark) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
