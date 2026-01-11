import Foundation

struct LiveMetricPoint: Identifiable, Hashable {
    let id = UUID()
    /// Seconds since the start of the scan.
    let t: Double
    let value: Double
}
