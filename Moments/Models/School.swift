import Foundation

struct School: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let emailDomain: String
    let latCenter: Double
    let lngCenter: Double
    let latMin: Double?
    let latMax: Double?
    let lngMin: Double?
    let lngMax: Double?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emailDomain = "email_domain"
        case latCenter = "lat_center"
        case lngCenter = "lng_center"
        case latMin = "lat_min"
        case latMax = "lat_max"
        case lngMin = "lng_min"
        case lngMax = "lng_max"
        case createdAt = "created_at"
    }
}
