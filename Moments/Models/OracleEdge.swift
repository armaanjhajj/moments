import Foundation

enum InteractionType: String, Codable, Sendable {
    case viewProfile = "view_profile"
    case like
    case comment
    case dm
    case connect
    case overlap
    case room
}

struct OracleEdge: Identifiable, Codable, Sendable {
    let id: UUID
    let userFrom: UUID
    let userTo: UUID
    let schoolId: UUID
    let interactionType: InteractionType
    let weight: Double
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userFrom = "user_from"
        case userTo = "user_to"
        case schoolId = "school_id"
        case interactionType = "interaction_type"
        case weight
        case createdAt = "created_at"
    }
}

struct OracleNode: Codable, Sendable {
    let userId: UUID
    let schoolId: UUID
    var totalOutgoingWeight: Double?
    var topConnections: [String: Double]?
    var lastComputedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case schoolId = "school_id"
        case totalOutgoingWeight = "total_outgoing_weight"
        case topConnections = "top_connections"
        case lastComputedAt = "last_computed_at"
    }
}
