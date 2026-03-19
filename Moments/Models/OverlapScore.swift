import Foundation

struct OverlapScore: Codable, Sendable {
    let userA: UUID
    let userB: UUID
    let schoolId: UUID
    let score: Double
    let lastComputedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userA = "user_a"
        case userB = "user_b"
        case schoolId = "school_id"
        case score
        case lastComputedAt = "last_computed_at"
    }
}
