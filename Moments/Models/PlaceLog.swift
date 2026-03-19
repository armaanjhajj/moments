import Foundation

enum PlaceMood: String, Codable, Sendable, CaseIterable {
    case buzzing
    case chill
    case productive
    case party
    case reflective
    case goodVibes = "good_vibes"
}

struct PlaceLog: Identifiable, Codable, Sendable {
    let id: UUID
    let userId: UUID
    let schoolId: UUID
    let placeId: UUID
    let rating: Double
    let mood: PlaceMood
    var note: String?
    let loggedAt: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case schoolId = "school_id"
        case placeId = "place_id"
        case rating
        case mood
        case note
        case loggedAt = "logged_at"
        case createdAt = "created_at"
    }
}
