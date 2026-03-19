import Foundation
import Combine
import CoreLocation
import Supabase

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var currentPlaceId: UUID?
    @Published var currentPlaceName: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var ghostModeActive = false

    private let manager = CLLocationManager()
    private var places: [Place] = []
    private var pingTimer: Timer?
    private var schoolId: UUID?

    nonisolated override init() {
        super.init()
    }

    func configure() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 20
    }

    func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlways() {
        manager.requestAlwaysAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func setPlaces(_ places: [Place]) {
        self.places = places
    }

    func setSchoolId(_ id: UUID) {
        self.schoolId = id
    }

    var currentPlace: Place? {
        guard let coord = currentCoordinate else { return nil }
        return nearestPlace(to: coord)
    }

    func nearestPlace(to coordinate: CLLocationCoordinate2D) -> Place? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return places.min(by: {
            let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return location.distance(from: loc1) < location.distance(from: loc2)
        })
    }

    func distanceToPlace(_ place: Place) -> CLLocationDistance? {
        guard let coord = currentCoordinate else { return nil }
        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let placeLoc = CLLocation(latitude: place.latitude, longitude: place.longitude)
        return userLoc.distance(from: placeLoc)
    }

    // MARK: - Location Pinging (Overlap Engine)

    func startPinging() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.sendPing()
            }
        }
        // Send initial ping
        Task { await sendPing() }
    }

    func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func sendPing() async {
        guard !ghostModeActive,
              let coord = currentCoordinate,
              let place = nearestPlace(to: coord),
              let schoolId = self.schoolId else { return }

        // Only send place_id — never raw GPS
        do {
            try await AppSupabaseClient.shared.client
                .from("location_pings")
                .insert([
                    "user_id": AppSupabaseClient.shared.client.auth.session.user.id.uuidString,
                    "school_id": schoolId.uuidString,
                    "place_id": place.id.uuidString,
                ])
                .execute()
        } catch {
            print("[LocationManager] Ping failed: \(error)")
        }
    }

    func toggleGhostMode() {
        ghostModeActive.toggle()
        if ghostModeActive {
            stopPinging()
            // Auto-disable after 24h
            Task {
                try? await Task.sleep(for: .seconds(86400))
                ghostModeActive = false
                startPinging()
            }
        } else {
            startPinging()
        }
    }

    // MARK: - Region Monitoring for Drops

    func monitorDropRegion(dropId: UUID, latitude: Double, longitude: Double, radius: CLLocationDistance = 15) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: center, radius: radius, identifier: "drop-\(dropId.uuidString)")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        manager.startMonitoring(for: region)
    }

    func stopMonitoringDrop(dropId: UUID) {
        for region in manager.monitoredRegions {
            if region.identifier == "drop-\(dropId.uuidString)" {
                manager.stopMonitoring(for: region)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: @preconcurrency CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentCoordinate = location.coordinate

        if let nearest = nearestPlace(to: location.coordinate) {
            currentPlaceId = nearest.id
            currentPlaceName = nearest.name
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier.hasPrefix("drop-") else { return }
        let dropIdString = String(region.identifier.dropFirst(5))
        NotificationCenter.default.post(
            name: .dropUnlocked,
            object: nil,
            userInfo: ["dropId": dropIdString]
        )
    }
}

extension Notification.Name {
    static let dropUnlocked = Notification.Name("dropUnlocked")
}
