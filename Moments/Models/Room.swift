import Foundation

enum RoomVisibility: String, Codable, Sendable {
    case `public`
    case inviteOnly = "invite_only"
}

struct Room: Identifiable, Codable, Sendable {
    let id: UUID
    let schoolId: UUID
    let homePlaceId: UUID
    let name: String
    var description: String?
    let visibility: RoomVisibility
    var tags: [String]?
    let createdBy: UUID
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case schoolId = "school_id"
        case homePlaceId = "home_place_id"
        case name
        case description
        case visibility
        case tags
        case createdBy = "created_by"
        case createdAt = "created_at"
    }
}

struct RoomMember: Codable, Sendable {
    let roomId: UUID
    let userId: UUID
    let role: String
    let joinedAt: Date?

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case userId = "user_id"
        case role
        case joinedAt = "joined_at"
    }
}
