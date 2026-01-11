import Foundation
import SwiftData

@Model
final class VitalSign {
    var timestamp: Date
    var heartRate: Int
    var breathingRate: Int
    var notes: String?
    
    init(timestamp: Date = Date(), heartRate: Int, breathingRate: Int, notes: String? = nil) {
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.breathingRate = breathingRate
        self.notes = notes
    }
}

