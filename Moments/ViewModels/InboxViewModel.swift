import Foundation
import Combine
import Supabase

@MainActor
final class InboxViewModel: ObservableObject {
    @Published var sparks: [Spark] = []
    @Published var conversations: [Conversation] = []
    @Published var rooms: [Room] = []
    @Published var allRooms: [Room] = []
    @Published var lastMessages: [UUID: Message] = [:]
    @Published var sparkUsers: [UUID: MUser] = [:]
    @Published var conversationUsers: [UUID: MUser] = [:]
    @Published var isLoading = false

    private let supabase = AppSupabaseClient.shared.client

    func loadInbox(schoolId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        async let sparksTask: () = loadSparks(schoolId: schoolId)
        async let convsTask: () = loadConversations(schoolId: schoolId)
        async let roomsTask: () = loadMyRooms(schoolId: schoolId)
        async let allRoomsTask: () = loadAllRooms(schoolId: schoolId)
        _ = await (sparksTask, convsTask, roomsTask, allRoomsTask)
    }

    private func loadSparks(schoolId: UUID) async {
        do {
            let userId = try await supabase.auth.session.user.id
            sparks = try await supabase
                .from("sparks")
                .select()
                .eq("school_id", value: schoolId)
                .or("user_a.eq.\(userId),user_b.eq.\(userId)")
                .is("converted_at", value: nil)
                .order("created_at", ascending: false)
                .execute()
                .value

            // Filter out permanently dismissed
            sparks = sparks.filter { spark in
                if spark.userA == userId { return !(spark.permDismissedByA ?? false) }
                else { return !(spark.permDismissedByB ?? false) }
            }

            // Load spark user profiles
            let otherIds = sparks.map { $0.userA == userId ? $0.userB : $0.userA }
            for id in otherIds {
                if sparkUsers[id] == nil {
                    if let user: MUser = try? await supabase
                        .from("users")
                        .select()
                        .eq("id", value: id)
                        .single()
                        .execute()
                        .value {
                        sparkUsers[id] = user
                    }
                }
            }
        } catch {
            print("[Inbox] Failed to load sparks: \(error)")
        }
    }

    private func loadConversations(schoolId: UUID) async {
        do {
            let userId = try await supabase.auth.session.user.id
            conversations = try await supabase
                .from("conversations")
                .select()
                .eq("school_id", value: schoolId)
                .or("user_a.eq.\(userId),user_b.eq.\(userId)")
                .order("created_at", ascending: false)
                .execute()
                .value

            // Load last message + user profiles for each conversation
            for conv in conversations {
                let otherId = conv.userA == userId ? conv.userB : conv.userA
                if conversationUsers[otherId] == nil {
                    if let user: MUser = try? await supabase
                        .from("users")
                        .select()
                        .eq("id", value: otherId)
                        .single()
                        .execute()
                        .value {
                        conversationUsers[otherId] = user
                    }
                }

                if let msg: Message = try? await supabase
                    .from("messages")
                    .select()
                    .eq("conversation_id", value: conv.id)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .single()
                    .execute()
                    .value {
                    lastMessages[conv.id] = msg
                }
            }
        } catch {
            print("[Inbox] Failed to load conversations: \(error)")
        }
    }

    private func loadMyRooms(schoolId: UUID) async {
        do {
            let userId = try await supabase.auth.session.user.id
            let memberships: [RoomMember] = try await supabase
                .from("room_members")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value

            let roomIds = memberships.map { $0.roomId }
            if !roomIds.isEmpty {
                rooms = try await supabase
                    .from("rooms")
                    .select()
                    .eq("school_id", value: schoolId)
                    .in("id", values: roomIds.map { $0.uuidString })
                    .execute()
                    .value
            }
        } catch {
            print("[Inbox] Failed to load rooms: \(error)")
        }
    }

    private func loadAllRooms(schoolId: UUID) async {
        do {
            allRooms = try await supabase
                .from("rooms")
                .select()
                .eq("school_id", value: schoolId)
                .execute()
                .value
        } catch {
            print("[Inbox] Failed to load all rooms: \(error)")
        }
    }

    // MARK: - Spark Actions

    func dismissSpark(_ spark: Spark) async {
        do {
            let userId = try await supabase.auth.session.user.id
            let field = spark.userA == userId ? "dismissed_by_a_at" : "dismissed_by_b_at"

            try await supabase
                .from("sparks")
                .update([field: ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: spark.id)
                .execute()

            sparks.removeAll { $0.id == spark.id }
        } catch {
            print("[Inbox] Failed to dismiss spark: \(error)")
        }
    }

    func sayHi(to spark: Spark) async -> Conversation? {
        do {
            let userId = try await supabase.auth.session.user.id
            let otherId = spark.userA == userId ? spark.userB : spark.userA
            let (a, b) = userId < otherId ? (userId, otherId) : (otherId, userId)

            struct NewConversation: Encodable {
                let user_a: String
                let user_b: String
                let school_id: String
                let spark_context: SparkOverlapContext
            }

            let conv: Conversation = try await supabase
                .from("conversations")
                .insert(NewConversation(
                    user_a: a.uuidString,
                    user_b: b.uuidString,
                    school_id: spark.schoolId.uuidString,
                    spark_context: spark.overlapContext
                ))
                .select()
                .single()
                .execute()
                .value

            // Mark spark as converted
            try await supabase
                .from("sparks")
                .update(["converted_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: spark.id)
                .execute()

            sparks.removeAll { $0.id == spark.id }
            return conv
        } catch {
            print("[Inbox] Failed to say hi: \(error)")
            return nil
        }
    }

    // MARK: - Room Actions

    func joinRoom(_ room: Room) async -> Bool {
        do {
            let userId = try await supabase.auth.session.user.id
            try await supabase
                .from("room_members")
                .insert([
                    "room_id": room.id.uuidString,
                    "user_id": userId.uuidString,
                    "role": "member",
                ])
                .execute()
            rooms.append(room)
            return true
        } catch {
            print("[Inbox] Failed to join room: \(error)")
            return false
        }
    }
}
