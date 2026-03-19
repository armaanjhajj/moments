import Foundation

enum ContentType: String, Codable, Sendable {
    case photo
    case video
    case text
    case song
    case voice
}

struct Moment: Identifiable, Codable, Sendable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let placeId: UUID
    let contentType: ContentType
    var contentUrl: String?
    var textContent: String?
    var songTitle: String?
    var songArtist: String?
    var songArtUrl: String?
    var isDrop: Bool?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case placeId = "place_id"
        case contentType = "content_type"
        case contentUrl = "content_url"
        case textContent = "text_content"
        case songTitle = "song_title"
        case songArtist = "song_artist"
        case songArtUrl = "song_art_url"
        case isDrop = "is_drop"
        case createdAt = "created_at"
    }
}
