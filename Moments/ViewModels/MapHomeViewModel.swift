import Foundation
import Combine
import MapKit
import SwiftUI
import Supabase

@MainActor
final class MapHomeViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var drops: [Drop] = []
    @Published var isLoading = false
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedPlace: Place?

    private let supabase = AppSupabaseClient.shared.client

    func loadMapData(schoolId: UUID, campusCenter: CLLocationCoordinate2D?) async {
        isLoading = true
        defer { isLoading = false }

        async let placesTask: () = loadPlaces(schoolId: schoolId)
        async let dropsTask: () = loadDrops(schoolId: schoolId)
        _ = await (placesTask, dropsTask)

        if let center = campusCenter {
            cameraPosition = .region(MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }
    }

    private func loadPlaces(schoolId: UUID) async {
        do {
            places = try await supabase
                .from("places")
                .select()
                .eq("school_id", value: schoolId)
                .execute()
                .value
        } catch {
            print("[MapHome] Failed to load places: \(error)")
        }
    }

    private func loadDrops(schoolId: UUID) async {
        do {
            drops = try await supabase
                .from("drops")
                .select()
                .eq("school_id", value: schoolId)
                .execute()
                .value
        } catch {
            print("[MapHome] Failed to load drops: \(error)")
        }
    }

    func placeIcon(for type: PlaceType) -> String {
        switch type {
        case .library: return "books.vertical.fill"
        case .dining: return "fork.knife"
        case .gym: return "figure.run"
        case .outdoor: return "leaf.fill"
        case .building: return "building.2.fill"
        case .dorm: return "house.fill"
        }
    }

    func dropGlowColor(for drop: Drop) -> SwiftUI.Color {
        // We need the moment's content_type to determine color
        // For now use a default; this gets enriched when we load full drop data
        .orange
    }
}
