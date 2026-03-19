import Foundation
import Combine
import Supabase

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var moments: [Moment] = []
    @Published var placeLogs: [PlaceLog] = []
    @Published var visitedPlaces: [Place] = []
    @Published var visitCounts: [UUID: Int] = [:]
    @Published var connectionCount: Int = 0
    @Published var activeDrops: [Drop] = []
    @Published var isLoading = false

    private let supabase = AppSupabaseClient.shared.client

    func loadProfile(userId: UUID, schoolId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        async let momentsTask: () = loadMoments(userId: userId, schoolId: schoolId)
        async let logsTask: () = loadPlaceLogs(userId: userId, schoolId: schoolId)
        async let connectionsTask: () = loadConnectionCount(userId: userId)
        async let dropsTask: () = loadDrops(userId: userId, schoolId: schoolId)
        _ = await (momentsTask, logsTask, connectionsTask, dropsTask)
    }

    private func loadMoments(userId: UUID, schoolId: UUID) async {
        do {
            moments = try await supabase
                .from("moments")
                .select()
                .eq("user_id", value: userId)
                .eq("school_id", value: schoolId)
                .order("created_at", ascending: false)
                .limit(100)
                .execute()
                .value
        } catch {
            print("[Profile] Failed to load moments: \(error)")
        }
    }

    private func loadPlaceLogs(userId: UUID, schoolId: UUID) async {
        do {
            placeLogs = try await supabase
                .from("place_logs")
                .select()
                .eq("user_id", value: userId)
                .eq("school_id", value: schoolId)
                .order("created_at", ascending: false)
                .execute()
                .value

            // Compute visit counts per place
            var counts: [UUID: Int] = [:]
            for log in placeLogs {
                counts[log.placeId, default: 0] += 1
            }
            visitCounts = counts
        } catch {
            print("[Profile] Failed to load logs: \(error)")
        }
    }

    private func loadConnectionCount(userId: UUID) async {
        do {
            let connections: [Connection] = try await supabase
                .from("connections")
                .select()
                .or("user_a.eq.\(userId),user_b.eq.\(userId)")
                .execute()
                .value
            connectionCount = connections.count
        } catch {
            print("[Profile] Failed to load connections: \(error)")
        }
    }

    private func loadDrops(userId: UUID, schoolId: UUID) async {
        do {
            activeDrops = try await supabase
                .from("drops")
                .select()
                .eq("user_id", value: userId)
                .eq("school_id", value: schoolId)
                .order("created_at", ascending: false)
                .execute()
                .value
        } catch {
            print("[Profile] Failed to load drops: \(error)")
        }
    }

    var momentsByPlace: [(placeId: UUID, moments: [Moment])] {
        let grouped = Dictionary(grouping: moments) { $0.placeId }
        return grouped.map { (placeId: $0.key, moments: $0.value) }
            .sorted { $0.moments.count > $1.moments.count }
    }
}
