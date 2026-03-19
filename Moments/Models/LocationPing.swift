import Foundation

struct LocationPing: Identifiable, Codable, Sendable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let placeId: UUID
    let pingedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case placeId = "place_id"
        case pingedAt = "pinged_at"
    }
}
