import Foundation

struct CopresenceEvent: Identifiable, Codable, Sendable {
    let id: UUID
    let userA: UUID
    let userB: UUID
    let placeId: UUID
    let schoolId: UUID
    let occurredAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userA = "user_a"
        case userB = "user_b"
        case placeId = "place_id"
        case schoolId = "school_id"
        case occurredAt = "occurred_at"
    }
}
