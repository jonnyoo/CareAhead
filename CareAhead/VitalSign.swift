import Foundation
import SwiftData

@Model
final class VitalSign {
    var timestamp: Date
    var heartRate: Int
    var breathingRate: Int
    var sleepHours: Double?
    var notes: String?
    
    init(timestamp: Date = Date(), heartRate: Int, breathingRate: Int, sleepHours: Double? = nil, notes: String? = nil) {
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.breathingRate = breathingRate
        self.sleepHours = sleepHours
        self.notes = notes
    }
}

