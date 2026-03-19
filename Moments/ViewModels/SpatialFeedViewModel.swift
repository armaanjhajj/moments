import Foundation
import Combine
import Supabase

@MainActor
final class SpatialFeedViewModel: ObservableObject {
    @Published var myHistory: [Moment] = []
    @Published var campusFeed: [Moment] = []
    @Published var isLoading = false
    @Published var selectedMode: FeedMode = .campus

    private let supabase = AppSupabaseClient.shared.client

    enum FeedMode: String, CaseIterable {
        case history = "Your History"
        case campus = "Campus Feed"
    }

    func loadFeed(schoolId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        async let historyTask: () = loadMyHistory(schoolId: schoolId)
        async let campusTask: () = loadCampusFeed(schoolId: schoolId)
        _ = await (historyTask, campusTask)
    }

    private func loadMyHistory(schoolId: UUID) async {
        do {
            let userId = try await supabase.auth.session.user.id
            myHistory = try await supabase
                .from("moments")
                .select()
                .eq("school_id", value: schoolId)
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
        } catch {
            print("[Feed] Failed to load history: \(error)")
        }
    }

    private func loadCampusFeed(schoolId: UUID) async {
        do {
            let userId = try await supabase.auth.session.user.id

            // Get connection IDs
            let connections: [Connection] = try await supabase
                .from("connections")
                .select()
                .or("user_a.eq.\(userId),user_b.eq.\(userId)")
                .execute()
                .value

            let connectionIds = connections.map { conn in
                conn.userA == userId ? conn.userB : conn.userA
            }

            if connectionIds.isEmpty {
                campusFeed = []
                return
            }

            // Connections' content — school-scoped, never global
            let idList = connectionIds.map { $0.uuidString }.joined(separator: ",")
            campusFeed = try await supabase
                .from("moments")
                .select()
                .eq("school_id", value: schoolId)
                .in("user_id", values: connectionIds.map { $0.uuidString })
                .order("created_at", ascending: false)
                .limit(30)
                .execute()
                .value
        } catch {
            print("[Feed] Failed to load campus feed: \(error)")
        }
    }
}
