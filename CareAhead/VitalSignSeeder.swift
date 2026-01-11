import Foundation
import SwiftData

enum VitalSignSeeder {
    @MainActor
    static func seedIfNeeded(modelContext: ModelContext, days: Int = 100) throws {
        let existingCount = try modelContext.fetchCount(FetchDescriptor<VitalSign>())
        if existingCount > 0 {
            try backfillSleepIfNeeded(modelContext: modelContext)
            return
        }

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        for daysAgo in 1...days {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) else { continue }
            let timestamp = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day

            let heartRate = Int.random(in: 55...95)
            let breathingRate = Int.random(in: 12...20)
            let sleepHours = Double.random(in: 6.0...9.5)

            modelContext.insert(
                VitalSign(
                    timestamp: timestamp,
                    heartRate: heartRate,
                    breathingRate: breathingRate,
                    sleepHours: sleepHours
                )
            )
        }

        try modelContext.save()
    }

    @MainActor
    private static func backfillSleepIfNeeded(modelContext: ModelContext) throws {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        // Fetch a reasonable amount; this app is small and local.
        let all = try modelContext.fetch(FetchDescriptor<VitalSign>())
        var didChange = false

        for vital in all {
            guard vital.sleepHours == nil else { continue }
            // Only backfill for prior days; keep today as "no data" unless the user logs it.
            if calendar.isDate(vital.timestamp, inSameDayAs: todayStart) { continue }
            vital.sleepHours = Double.random(in: 6.0...9.5)
            didChange = true
        }

        if didChange {
            try modelContext.save()
        }
    }
}
