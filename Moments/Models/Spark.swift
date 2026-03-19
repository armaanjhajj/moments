import Foundation

struct SparkOverlapContext: Codable, Sendable {
    var placeName: String?
    var visitCount: Int?
    var sharedInterest: String?

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case visitCount = "visit_count"
        case sharedInterest = "shared_interest"
    }
}

struct Spark: Identifiable, Codable, Sendable {
    let id: UUID
    let userA: UUID
    let userB: UUID
    let schoolId: UUID
    let overlapScore: Double
    let overlapContext: SparkOverlapContext
    var dismissedByAAt: Date?
    var dismissedByBAt: Date?
    var permDismissedByA: Bool?
    var permDismissedByB: Bool?
    var convertedAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userA = "user_a"
        case userB = "user_b"
        case schoolId = "school_id"
        case overlapScore = "overlap_score"
        case overlapContext = "overlap_context"
        case dismissedByAAt = "dismissed_by_a_at"
        case dismissedByBAt = "dismissed_by_b_at"
        case permDismissedByA = "perm_dismissed_by_a"
        case permDismissedByB = "perm_dismissed_by_b"
        case convertedAt = "converted_at"
        case createdAt = "created_at"
    }
}
