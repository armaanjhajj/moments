import Foundation

enum PlaceType: String, Codable, Sendable, CaseIterable {
    case library
    case dining
    case gym
    case outdoor
    case building
    case dorm
}

struct Place: Identifiable, Codable, Sendable {
    let id: UUID
    let schoolId: UUID
    let name: String
    let type: PlaceType
    let latitude: Double
    let longitude: Double
    let address: String?
    let hours: [String: String]?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case schoolId = "school_id"
        case name
        case type
        case latitude
        case longitude
        case address
        case hours
        case createdAt = "created_at"
    }
}
