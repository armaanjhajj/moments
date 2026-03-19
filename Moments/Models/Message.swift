import Foundation

enum MessageContentType: String, Codable, Sendable {
    case text
    case momentCard = "moment_card"
    case placeCard = "place_card"
}

struct Message: Identifiable, Codable, Sendable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let schoolId: UUID
    let content: String
    var contentType: MessageContentType?
    var referencedId: UUID?
    var disappearsAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case schoolId = "school_id"
        case content
        case contentType = "content_type"
        case referencedId = "referenced_id"
        case disappearsAt = "disappears_at"
        case createdAt = "created_at"
    }
}

struct Conversation: Identifiable, Codable, Sendable {
    let id: UUID
    let userA: UUID
    let userB: UUID
    let schoolId: UUID
    var sparkContext: SparkOverlapContext?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userA = "user_a"
        case userB = "user_b"
        case schoolId = "school_id"
        case sparkContext = "spark_context"
        case createdAt = "created_at"
    }
}
