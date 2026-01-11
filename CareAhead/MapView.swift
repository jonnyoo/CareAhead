import SwiftUI
import MapKit
import CoreLocation
import Combine

struct MapView: View {
    var body: some View {
        HealthcareMapScreen()
    }
}

#Preview {
    MapView()
}

// MARK: - Screen

struct HealthcareMapScreen: View {
    @StateObject private var location = LocationManager()
    @StateObject private var vm = HealthcareMapViewModel()

    @State private var selectedMapItem: MKMapItem?
    @State private var hasInitialCentered = false
    @State private var hasSearched = false

    var body: some View {
        ZStack {
            Map(position: $vm.cameraPosition, selection: $selectedMapItem) {
                UserAnnotation()

                ForEach(vm.providers) { provider in
                    Annotation("", coordinate: provider.coordinate) {
                        ProviderPinView(isClosest: provider.isClosest)
                    }
                    .tag(provider.mapItem)
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .onAppear {
                location.requestPermission()
            }
            .onChange(of: location.currentLocation) { _, loc in
                guard let loc else { return }
                
                // On first location update, center on user
                if !hasInitialCentered {
                    hasInitialCentered = true
                    vm.centerOnUserLocation(loc)
                }
                
                // Search only once when map page is opened
                if !hasSearched {
                    hasSearched = true
                    vm.searchNearbyHealthcare(around: loc)
                }
            }
            .onChange(of: selectedMapItem) { _, item in
                vm.select(mapItem: item)
            }

            // Bottom overlay removed - using sheet instead
        }
        .onChange(of: vm.selected?.mapItem) { _, newItem in
            // Keep Map selection + bottom card in sync
            selectedMapItem = newItem
        }
        .sheet(isPresented: $vm.isPanelVisible) {
            if let selected = vm.selected {
                ProviderBottomCard(
                    provider: selected,
                    isSaved: vm.isSaved(selected),
                    onClose: { vm.isPanelVisible = false },
                    onDirections: { vm.openDirections(to: selected.mapItem) },
                    onCall: { vm.call(selected.mapItem) },
                    onToggleSave: { vm.toggleSave(selected) },
                    onShare: { vm.shareText(for: selected) }
                )
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
            }
        }
    }
}

// MARK: - View Model

final class HealthcareMapViewModel: ObservableObject {
    @Published var providers: [HealthcareProvider] = []
    @Published var selected: HealthcareProvider?
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var isPanelVisible: Bool = false

    private var savedIDs: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "saved_providers") ?? [])

    func searchNearbyHealthcare(around location: CLLocation) {
        let queries = ["Hospital", "Clinic", "Urgent Care", "Walk-in Clinic", "Medical Center", "Pharmacy"]

        Task { @MainActor in
            var items: [MKMapItem] = []

            // Run a few searches and merge results
            for q in queries {
                do {
                    let result = try await localSearch(query: q, around: location)
                    items.append(contentsOf: result)
                } catch {
                    // ignore individual failures
                }
            }

            // De-dupe (name + coordinate is usually enough)
            let unique = dedupe(items)

            let mapped: [HealthcareProvider] = unique
                .map { item in
                    let coord = item.placemark.coordinate
                    let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    let dist = location.distance(from: loc)
                    return HealthcareProvider(mapItem: item, distanceMeters: dist)
                }
                .sorted { $0.distanceMeters < $1.distanceMeters }

            var final = mapped
            if let first = final.first {
                final = final.map { p in
                    var copy = p
                    copy.isClosest = (p.id == first.id)
                    return copy
                }

                selected = final.first
                // Don't auto-show sheet, only show when user selects a pin

                // Center camera on closest provider to "bring to attention"
                let region = MKCoordinateRegion(
                    center: first.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
                cameraPosition = .region(region)
            }

            providers = final
        }
    }

    func select(mapItem: MKMapItem?) {
        guard let mapItem else { return }
        if let match = providers.first(where: { $0.mapItem == mapItem }) {
            selected = match
            isPanelVisible = true
        }
    }

    func centerOnUserLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(region)
        }
    }

    // MARK: Actions

    func openDirections(to item: MKMapItem) {
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    func call(_ item: MKMapItem) {
        guard let phone = item.phoneNumber else { return }
        let digits = phone.filter { "0123456789+".contains($0) }
        guard let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }

    func isSaved(_ provider: HealthcareProvider) -> Bool {
        savedIDs.contains(provider.storageID)
    }

    func toggleSave(_ provider: HealthcareProvider) {
        if savedIDs.contains(provider.storageID) {
            savedIDs.remove(provider.storageID)
        } else {
            savedIDs.insert(provider.storageID)
        }
        UserDefaults.standard.set(Array(savedIDs), forKey: "saved_providers")
        objectWillChange.send()
    }

    func shareText(for provider: HealthcareProvider) -> String {
        let item = provider.mapItem
        let name = item.name ?? "Healthcare provider"
        let addr = item.placemark.postalAddressString
        let phone = item.phoneNumber.map { "Phone: \($0)" } ?? ""
        let lat = provider.coordinate.latitude
        let lon = provider.coordinate.longitude
        let mapsURL = "http://maps.apple.com/?ll=\(lat),\(lon)&q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
        return [name, addr, phone, mapsURL].filter { !$0.isEmpty }.joined(separator: "\n")
    }

    // MARK: Helpers

    private func dedupe(_ items: [MKMapItem]) -> [MKMapItem] {
        var seen = Set<String>()
        var out: [MKMapItem] = []
        for item in items {
            let c = item.placemark.coordinate
            let key = "\(item.name ?? "")|\(c.latitude.rounded(to: 5))|\(c.longitude.rounded(to: 5))"
            if seen.insert(key).inserted { out.append(item) }
        }
        return out
    }

    private func localSearch(query: String, around location: CLLocation) async throws -> [MKMapItem] {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        req.resultTypes = .pointOfInterest

        req.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        )

        let search = MKLocalSearch(request: req)
        let response = try await search.start()
        return response.mapItems
    }
}

// MARK: - Models

struct HealthcareProvider: Identifiable, Equatable {
    let id = UUID()
    let mapItem: MKMapItem
    let distanceMeters: CLLocationDistance
    var isClosest: Bool = false

    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }

    var storageID: String {
        let c = coordinate
        return "\(mapItem.name ?? "Unknown")|\(c.latitude.rounded(to: 5))|\(c.longitude.rounded(to: 5))"
    }

    static func == (lhs: HealthcareProvider, rhs: HealthcareProvider) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - UI

private struct ProviderPinView: View {
    let isClosest: Bool

    var body: some View {
        ZStack {
            if isClosest {
                Circle()
                    .stroke(Color("AccentColor").opacity(0.35), lineWidth: 10)
                    .frame(width: 44, height: 44)
                Circle()
                    .fill(Color("AccentColor").opacity(0.18))
                    .frame(width: 54, height: 54)
            }

            Circle()
                .fill(isClosest ? Color("AccentColor") : Color.black.opacity(0.85))
                .frame(width: 28, height: 28)

            Image(systemName: "cross.case.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

private struct ProviderBottomCard: View {
    let provider: HealthcareProvider
    let isSaved: Bool
    let onClose: () -> Void
    let onDirections: () -> Void
    let onCall: () -> Void
    let onToggleSave: () -> Void
    let onShare: () -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.mapItem.name ?? "Healthcare provider")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.88))

                Text(provider.mapItem.pointOfInterestSubtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.55))
            }

            HStack(spacing: 10) {
                PillButton(
                    title: provider.distanceText,
                    systemImage: "location.fill",
                    action: onDirections
                )
                .frame(maxWidth: .infinity)

                PillButton(
                    title: "Call",
                    systemImage: "phone.fill",
                    isEnabled: provider.mapItem.phoneNumber != nil,
                    action: onCall
                )
                .frame(maxWidth: .infinity)

                PillButton(
                    title: isSaved ? "Saved" : "Save",
                    systemImage: isSaved ? "bookmark.fill" : "bookmark",
                    action: onToggleSave
                )
                .frame(maxWidth: .infinity)
            }

            ShareLink(item: onShare()) {
                Text("Send info to Hospital")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("AccentColor"))
                    )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct PillButton: View {
    let title: String
    let systemImage: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(isEnabled ? Color("AccentColor") : Color.gray.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?

    private let manager = CLLocationManager()
    private var didStart = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        if !didStart {
            didStart = true
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // You could surface an error state here.
    }
}

// MARK: - Map Item helpers

private extension MKMapItem {
    var pointOfInterestSubtitle: String {
        // If you want "Hospital / Clinic" etc. from category, it's not always available.
        // This gives something reasonable:
        if let name = placemark.thoroughfare, !name.isEmpty {
            return "Healthcare provider"
        }
        return "Healthcare provider"
    }
}

private extension MKPlacemark {
    var postalAddressString: String {
        let parts = [
            subThoroughfare,
            thoroughfare,
            locality,
            administrativeArea,
            postalCode
        ].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.joined(separator: " ")
    }
}

// MARK: - Formatting

private extension HealthcareProvider {
    var distanceText: String {
        let km = distanceMeters / 1000.0
        if km < 1 {
            let m = Int(distanceMeters.rounded())
            return "\(m)m"
        } else {
            return String(format: "%.0fkm", km)
        }
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let p = pow(10.0, Double(places))
        return (self * p).rounded() / p
    }
}
