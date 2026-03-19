import Foundation
import Combine
import Supabase
import Realtime

@MainActor
final class RealtimeManager: ObservableObject {
    @Published var presenceCounts: [UUID: Int] = [:]  // placeId -> active user count
    @Published var connectionAvatarsNearby: [UUID: [MUser]] = [:]  // placeId -> users

    private var presenceChannel: RealtimeChannelV2?
    private var messageChannels: [UUID: RealtimeChannelV2] = [:]

    func subscribeToPresence(schoolId: UUID) async {
        let channel = AppSupabaseClient.shared.client.realtimeV2
            .channel("campus-presence-\(schoolId.uuidString)")

        presenceChannel = channel

        let changes = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "location_pings",
            filter: "school_id=eq.\(schoolId.uuidString)"
        )

        await channel.subscribe()

        Task {
            for await insert in changes {
                if let placeIdStr = insert.record["place_id"]?.stringValue,
                   let placeId = UUID(uuidString: placeIdStr) {
                    presenceCounts[placeId, default: 0] += 1
                }
            }
        }
    }

    func refreshPresenceCounts(schoolId: UUID) async {
        do {
            struct PingCount: Decodable {
                let placeId: UUID
                let count: Int

                enum CodingKeys: String, CodingKey {
                    case placeId = "place_id"
                    case count
                }
            }

            // Get pings from last 30 minutes grouped by place
            let thirtyMinAgo = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800))
            let response: [LocationPing] = try await AppSupabaseClient.shared.client
                .from("location_pings")
                .select()
                .eq("school_id", value: schoolId)
                .gte("pinged_at", value: thirtyMinAgo)
                .execute()
                .value

            var counts: [UUID: Set<UUID>] = [:]
            for ping in response {
                counts[ping.placeId, default: []].insert(ping.userId)
            }
            presenceCounts = counts.mapValues { $0.count }
        } catch {
            print("[Realtime] Failed to refresh presence: \(error)")
        }
    }

    func subscribeToMessages(conversationId: UUID, onMessage: @escaping (Message) -> Void) async {
        let channel = AppSupabaseClient.shared.client.realtimeV2
            .channel("conversation-\(conversationId.uuidString)")

        messageChannels[conversationId] = channel

        let changes = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages",
            filter: "conversation_id=eq.\(conversationId.uuidString)"
        )

        await channel.subscribe()

        Task {
            for await insert in changes {
                if let data = try? JSONSerialization.data(withJSONObject: insert.record),
                   let message = try? JSONDecoder().decode(Message.self, from: data) {
                    await MainActor.run { onMessage(message) }
                }
            }
        }
    }

    func unsubscribeFromMessages(conversationId: UUID) async {
        if let channel = messageChannels.removeValue(forKey: conversationId) {
            await channel.unsubscribe()
        }
    }

    func unsubscribeAll() async {
        if let channel = presenceChannel {
            await channel.unsubscribe()
        }
        for (_, channel) in messageChannels {
            await channel.unsubscribe()
        }
        messageChannels.removeAll()
    }
}
