import Foundation
import Combine
import Supabase

@MainActor
final class PlaceProfileViewModel: ObservableObject {
    @Published var recentMoments: [Moment] = []
    @Published var activeDrops: [Drop] = []
    @Published var placeLogs: [PlaceLog] = []
    @Published var rooms: [Room] = []
    @Published var overlapEvents: [CopresenceEvent] = []
    @Published var averageRating: Double = 0
    @Published var moodDistribution: [String: Int] = [:]
    @Published var regulars: [(userId: UUID, count: Int)] = []
    @Published var userVisitCount: Int = 0
    @Published var isLoading = false

    private let supabase = AppSupabaseClient.shared.client

    func loadAll(place: Place) async {
        isLoading = true
        defer { isLoading = false }

        async let moments: () = loadRecentMoments(place: place)
        async let drops: () = loadActiveDrops(place: place)
        async let logs: () = loadPlaceLogs(place: place)
        async let roomsLoad: () = loadRooms(place: place)
        async let overlaps: () = loadOverlaps(place: place)
        _ = await (moments, drops, logs, roomsLoad, overlaps)

        computeAggregates()
    }

    private func loadRecentMoments(place: Place) async {
        do {
            let yesterday = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400))
            recentMoments = try await supabase
                .from("moments")
                .select()
                .eq("place_id", value: place.id)
                .eq("school_id", value: place.schoolId)
                .gte("created_at", value: yesterday)
                .order("created_at", ascending: false)
                .limit(20)
                .execute()
                .value
        } catch {
            print("[PlaceProfile] Failed to load moments: \(error)")
        }
    }

    private func loadActiveDrops(place: Place) async {
        do {
            activeDrops = try await supabase
                .from("drops")
                .select()
                .eq("place_id", value: place.id)
                .eq("school_id", value: place.schoolId)
                .execute()
                .value
        } catch {
            print("[PlaceProfile] Failed to load drops: \(error)")
        }
    }

    private func loadPlaceLogs(place: Place) async {
        do {
            placeLogs = try await supabase
                .from("place_logs")
                .select()
                .eq("place_id", value: place.id)
                .eq("school_id", value: place.schoolId)
                .order("created_at", ascending: false)
                .limit(100)
                .execute()
                .value
        } catch {
            print("[PlaceProfile] Failed to load logs: \(error)")
        }
    }

    private func loadRooms(place: Place) async {
        do {
            rooms = try await supabase
                .from("rooms")
                .select()
                .eq("home_place_id", value: place.id)
                .eq("school_id", value: place.schoolId)
                .execute()
                .value
        } catch {
            print("[PlaceProfile] Failed to load rooms: \(error)")
        }
    }

    private func loadOverlaps(place: Place) async {
        do {
            let userId = try await supabase.auth.session.user.id
            overlapEvents = try await supabase
                .from("copresence_events")
                .select()
                .eq("place_id", value: place.id)
                .or("user_a.eq.\(userId),user_b.eq.\(userId)")
                .order("occurred_at", ascending: false)
                .limit(20)
                .execute()
                .value
        } catch {
            print("[PlaceProfile] Failed to load overlaps: \(error)")
        }
    }

    private func computeAggregates() {
        guard !placeLogs.isEmpty else { return }

        // Average rating
        let totalRating = placeLogs.reduce(0.0) { $0 + $1.rating }
        averageRating = totalRating / Double(placeLogs.count)

        // Mood distribution
        var moods: [String: Int] = [:]
        for log in placeLogs {
            moods[log.mood.rawValue, default: 0] += 1
        }
        moodDistribution = moods

        // Regulars (top 5 by log count)
        var userCounts: [UUID: Int] = [:]
        for log in placeLogs {
            userCounts[log.userId, default: 0] += 1
        }
        regulars = userCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (userId: $0.key, count: $0.value) }
    }

    func submitLog(place: Place, rating: Double, mood: PlaceMood, note: String?) async -> Bool {
        do {
            let userId = try await supabase.auth.session.user.id
            var record: [String: String] = [
                "user_id": userId.uuidString,
                "school_id": place.schoolId.uuidString,
                "place_id": place.id.uuidString,
                "rating": String(rating),
                "mood": mood.rawValue,
            ]
            if let note, !note.isEmpty {
                record["note"] = note
            }

            try await supabase
                .from("place_logs")
                .insert(record)
                .execute()

            await loadPlaceLogs(place: place)
            computeAggregates()
            return true
        } catch {
            print("[PlaceProfile] Failed to submit log: \(error)")
            return false
        }
    }
}
