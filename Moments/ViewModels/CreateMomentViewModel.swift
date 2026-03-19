import Foundation
import Combine
import PhotosUI
import Supabase

@MainActor
final class CreateMomentViewModel: ObservableObject {
    @Published var contentType: ContentType = .text
    @Published var textContent = ""
    @Published var songTitle = ""
    @Published var songArtist = ""
    @Published var selectedImageData: Data?
    @Published var isSubmitting = false
    @Published var error: String?

    // Drop settings
    @Published var isDrop = false
    @Published var dropVisibility: DropVisibility = .public
    @Published var dropDuration: DropDuration = .oneDay
    @Published var dropHint = ""

    private let supabase = AppSupabaseClient.shared.client

    func submit(placeId: UUID, schoolId: UUID) async -> Bool {
        isSubmitting = true
        error = nil
        defer { isSubmitting = false }

        do {
            let userId = try await supabase.auth.session.user.id
            var contentUrl: String?

            // Upload media if present
            if let imageData = selectedImageData {
                let momentId = UUID()
                let path = "\(schoolId.uuidString)/\(userId.uuidString)/\(momentId.uuidString).jpg"
                try await supabase.storage
                    .from("moments-media")
                    .upload(path, data: imageData, options: .init(contentType: "image/jpeg"))
                contentUrl = path
            }

            // Create moment
            var record: [String: String] = [
                "user_id": userId.uuidString,
                "school_id": schoolId.uuidString,
                "place_id": placeId.uuidString,
                "content_type": contentType.rawValue,
                "is_drop": isDrop ? "true" : "false",
            ]

            if !textContent.isEmpty { record["text_content"] = textContent }
            if let url = contentUrl { record["content_url"] = url }
            if !songTitle.isEmpty { record["song_title"] = songTitle }
            if !songArtist.isEmpty { record["song_artist"] = songArtist }

            struct InsertResult: Decodable {
                let id: UUID
            }

            let momentResult: InsertResult = try await supabase
                .from("moments")
                .insert(record)
                .select("id")
                .single()
                .execute()
                .value

            // Create Drop record if applicable
            if isDrop {
                // Get place coordinates for the drop
                let place: Place = try await supabase
                    .from("places")
                    .select()
                    .eq("id", value: placeId)
                    .single()
                    .execute()
                    .value

                var dropRecord: [String: String] = [
                    "moment_id": momentResult.id.uuidString,
                    "user_id": userId.uuidString,
                    "school_id": schoolId.uuidString,
                    "place_id": placeId.uuidString,
                    "latitude": String(place.latitude),
                    "longitude": String(place.longitude),
                    "visibility": dropVisibility.rawValue,
                ]

                if !dropHint.isEmpty {
                    dropRecord["hint"] = String(dropHint.prefix(80))
                }

                let expiresAt = dropDuration.expirationDate
                if let expiresAt {
                    dropRecord["expires_at"] = ISO8601DateFormatter().string(from: expiresAt)
                }

                try await supabase
                    .from("drops")
                    .insert(dropRecord)
                    .execute()
            }

            return true
        } catch {
            self.error = "Failed to create: \(error.localizedDescription)"
            return false
        }
    }
}

enum DropDuration: String, CaseIterable {
    case oneDay = "24h"
    case oneWeek = "7 days"
    case oneMonth = "30 days"
    case forever = "Forever"

    var expirationDate: Date? {
        switch self {
        case .oneDay: return Date().addingTimeInterval(86400)
        case .oneWeek: return Date().addingTimeInterval(604800)
        case .oneMonth: return Date().addingTimeInterval(2592000)
        case .forever: return nil
        }
    }
}
