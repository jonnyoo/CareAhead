import Foundation
import SwiftData

enum VitalSignSeeder {
    @MainActor
    static func seedIfNeeded(modelContext: ModelContext, days: Int = 100) throws {
        let existingCount = try modelContext.fetchCount(FetchDescriptor<VitalSign>())
        guard existingCount == 0 else { return }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        for daysAgo in 1...days {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) else { continue }
            let timestamp = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day

            let heartRate = Int.random(in: 55...95)
            let breathingRate = Int.random(in: 12...20)

            modelContext.insert(VitalSign(timestamp: timestamp, heartRate: heartRate, breathingRate: breathingRate))
        }

        try modelContext.save()
    }
}
