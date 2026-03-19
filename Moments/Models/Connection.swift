import Foundation

struct Connection: Identifiable, Codable, Sendable {
    let id: UUID
    let userA: UUID
    let userB: UUID
    let schoolId: UUID
    let connectedAt: Date?
    let sparkId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case userA = "user_a"
        case userB = "user_b"
        case schoolId = "school_id"
        case connectedAt = "connected_at"
        case sparkId = "spark_id"
    }
}
