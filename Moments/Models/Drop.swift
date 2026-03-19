import Foundation

enum DropVisibility: String, Codable, Sendable {
    case `public`
    case connections
    case specific
}

struct Drop: Identifiable, Codable, Sendable {
    let id: UUID
    let momentId: UUID
    let userId: UUID
    let schoolId: UUID
    let placeId: UUID
    let latitude: Double
    let longitude: Double
    let visibility: DropVisibility
    var specificUserIds: [UUID]?
    var hint: String?
    var expiresAt: Date?
    var roomId: UUID?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case momentId = "moment_id"
        case userId = "user_id"
        case schoolId = "school_id"
        case placeId = "place_id"
        case latitude
        case longitude
        case visibility
        case specificUserIds = "specific_user_ids"
        case hint
        case expiresAt = "expires_at"
        case roomId = "room_id"
        case createdAt = "created_at"
    }
}

struct DropFind: Identifiable, Codable, Sendable {
    let id: UUID
    let dropId: UUID
    let finderId: UUID
    let foundAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case dropId = "drop_id"
        case finderId = "finder_id"
        case foundAt = "found_at"
    }
}
