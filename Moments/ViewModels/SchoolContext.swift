import Foundation
import Combine
import CoreLocation
import Supabase

@MainActor
final class SchoolContext: ObservableObject {
    @Published var currentSchool: School?
    @Published var schoolId: UUID?

    var campusCenter: CLLocationCoordinate2D? {
        guard let school = currentSchool else { return nil }
        return CLLocationCoordinate2D(latitude: school.latCenter, longitude: school.lngCenter)
    }

    var campusBounds: (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D)? {
        guard let school = currentSchool,
              let latMin = school.latMin,
              let latMax = school.latMax,
              let lngMin = school.lngMin,
              let lngMax = school.lngMax else { return nil }
        return (
            min: CLLocationCoordinate2D(latitude: latMin, longitude: lngMin),
            max: CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
        )
    }

    func loadSchool(forId id: UUID) async {
        do {
            let school: School = try await AppSupabaseClient.shared.client
                .from("schools")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            self.currentSchool = school
            self.schoolId = school.id
        } catch {
            print("[SchoolContext] Failed to load school: \(error)")
        }
    }

    func loadSchool(forEmailDomain domain: String) async -> School? {
        do {
            let school: School = try await AppSupabaseClient.shared.client
                .from("schools")
                .select()
                .eq("email_domain", value: domain)
                .single()
                .execute()
                .value
            self.currentSchool = school
            self.schoolId = school.id
            return school
        } catch {
            print("[SchoolContext] No school found for domain \(domain): \(error)")
            return nil
        }
    }
}
