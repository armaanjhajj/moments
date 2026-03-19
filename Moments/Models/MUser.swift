import Foundation

struct MUser: Identifiable, Codable, Sendable {
    let id: UUID
    let schoolId: UUID
    var handle: String
    var displayName: String
    var phone: String?
    var avatarUrl: String?
    var bio: String?
    var gradYear: Int?
    var interests: [String]?
    var ghostModeUntil: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case schoolId = "school_id"
        case handle
        case displayName = "display_name"
        case phone
        case avatarUrl = "avatar_url"
        case bio
        case gradYear = "grad_year"
        case interests
        case ghostModeUntil = "ghost_mode_until"
        case createdAt = "created_at"
    }
}
