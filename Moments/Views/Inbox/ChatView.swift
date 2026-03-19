import SwiftUI
import Supabase

struct ChatView: View {
    let conversation: Conversation

    @EnvironmentObject private var realtimeManager: RealtimeManager
    @State private var messages: [Message] = []
    @State private var newMessage = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Spark context strip
                if let context = conversation.sparkContext {
                    sparkContextStrip(context)
                }

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                // Input bar
                HStack(spacing: 8) {
                    TextField("Message", text: $newMessage)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task { await send() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                    .disabled(newMessage.isEmpty || isSending)
                }
                .padding()
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadMessages()
            await realtimeManager.subscribeToMessages(conversationId: conversation.id) { msg in
                if !messages.contains(where: { $0.id == msg.id }) {
                    messages.append(msg)
                }
            }
        }
    }

    private func sparkContextStrip(_ context: SparkOverlapContext) -> some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.orange)
            if let place = context.placeName {
                Text("You both frequent \(place)")
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(.orange.opacity(0.08))
    }

    private func loadMessages() async {
        do {
            messages = try await AppSupabaseClient.shared.client
                .from("messages")
                .select()
                .eq("conversation_id", value: conversation.id)
                .order("created_at", ascending: true)
                .execute()
                .value
        } catch {
            print("[Chat] Failed to load messages: \(error)")
        }
    }

    private func send() async {
        let text = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        newMessage = ""
        isSending = true
        defer { isSending = false }

        do {
            let userId = try await AppSupabaseClient.shared.client.auth.session.user.id
            try await AppSupabaseClient.shared.client
                .from("messages")
                .insert([
                    "conversation_id": conversation.id.uuidString,
                    "sender_id": userId.uuidString,
                    "school_id": conversation.schoolId.uuidString,
                    "content": text,
                    "content_type": "text",
                ])
                .execute()
        } catch {
            print("[Chat] Failed to send: \(error)")
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            // Simple bubble — sender alignment handled when we have currentUserId
            VStack(alignment: .leading, spacing: 2) {
                Text(message.content)
                    .font(.subheadline)
                if let date = message.createdAt {
                    Text(date, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))

            Spacer()
        }
    }
}
