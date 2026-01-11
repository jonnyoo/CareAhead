import Foundation

struct GeminiInsightInput {
    let today: VitalSign
    let history: [VitalSign]

    struct Summary {
        let avgHeartRate: Double
        let avgBreathing: Double
        let avgSleepHours: Double?
        let minHeartRate: Int
        let maxHeartRate: Int
        let minBreathing: Int
        let maxBreathing: Int
        let minSleepHours: Double?
        let maxSleepHours: Double?
    }

    var summary: Summary {
        let heartRates = history.map { $0.heartRate }
        let breathingRates = history.map { $0.breathingRate }
        let sleepHours = history.compactMap { $0.sleepHours }

        let avgHR = Double(heartRates.reduce(0, +)) / Double(max(1, heartRates.count))
        let avgBR = Double(breathingRates.reduce(0, +)) / Double(max(1, breathingRates.count))
        let avgSleep = sleepHours.isEmpty ? nil : (sleepHours.reduce(0, +) / Double(sleepHours.count))

        return Summary(
            avgHeartRate: avgHR,
            avgBreathing: avgBR,
            avgSleepHours: avgSleep,
            minHeartRate: heartRates.min() ?? today.heartRate,
            maxHeartRate: heartRates.max() ?? today.heartRate,
            minBreathing: breathingRates.min() ?? today.breathingRate,
            maxBreathing: breathingRates.max() ?? today.breathingRate,
            minSleepHours: sleepHours.min(),
            maxSleepHours: sleepHours.max()
        )
    }
}

enum GeminiInsightPromptBuilder {
    static func build(input: GeminiInsightInput) -> String {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: input.today.timestamp)

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]

        let summary = input.summary

        let todaySleepLine: String = {
            if let hours = input.today.sleepHours {
                return "- Sleep: \(String(format: \"%.1f\", hours)) hours"
            }
            return "- Sleep: (no data)"
        }()

        let sleepSummaryLines: String = {
            guard let avg = summary.avgSleepHours else { return "" }
            let minLine: String
            let maxLine: String
            if let min = summary.minSleepHours, let max = summary.maxSleepHours {
                minLine = "- Sleep range: \(String(format: \"%.1f\", min))–\(String(format: \"%.1f\", max)) hours"
                maxLine = ""
            } else {
                minLine = ""
                maxLine = ""
            }

            return """
- Avg sleep: \(String(format: \"%.1f\", avg)) hours
\(minLine)
\(maxLine)
"""
            .split(separator: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n")
        }()

        let historyLines = input.history
            .sorted { $0.timestamp < $1.timestamp }
            .suffix(30)
            .map { vital -> String in
                let day = iso.string(from: calendar.startOfDay(for: vital.timestamp))
                if let sleep = vital.sleepHours {
                    return "- \(day): HR \(vital.heartRate) bpm, BR \(vital.breathingRate) rpm, Sleep \(String(format: \"%.1f\", sleep)) h"
                }
                return "- \(day): HR \(vital.heartRate) bpm, BR \(vital.breathingRate) rpm"
            }
            .joined(separator: "\n")

        return """
You are an assistant for a health-tracking app. Provide supportive, non-alarmist insights.
Do NOT give medical diagnoses. Include a brief disclaimer like: 'Not medical advice.'

Today (\(iso.string(from: todayStart))):
- Heart rate: \(input.today.heartRate) bpm
- Breathing rate: \(input.today.breathingRate) rpm
\(todaySleepLine)

History summary (last \(min(30, input.history.count)) days):
- Avg heart rate: \(String(format: "%.1f", summary.avgHeartRate)) bpm
- Avg breathing rate: \(String(format: "%.1f", summary.avgBreathing)) rpm
- Heart rate range: \(summary.minHeartRate)–\(summary.maxHeartRate) bpm
- Breathing rate range: \(summary.minBreathing)–\(summary.maxBreathing) rpm
\(sleepSummaryLines.isEmpty ? "" : sleepSummaryLines)

Daily history:
\(historyLines)

Output format:
1) Today’s insight (2-3 bullets)
2) Compared to your baseline (2-3 bullets)
3) If there’s a noticeable trend (up/down/volatile), mention it briefly
4) One gentle suggestion for today (sleep/hydration/stress) without medical claims
"""
    }
}
