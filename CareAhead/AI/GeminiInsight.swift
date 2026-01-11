import Foundation

struct GeminiInsightInput {
    let today: VitalSign
    let history: [VitalSign]

    struct Summary {
        let avgHeartRate: Double
        let avgBreathing: Double
        let minHeartRate: Int
        let maxHeartRate: Int
        let minBreathing: Int
        let maxBreathing: Int
    }

    var summary: Summary {
        let heartRates = history.map { $0.heartRate }
        let breathingRates = history.map { $0.breathingRate }

        let avgHR = Double(heartRates.reduce(0, +)) / Double(max(1, heartRates.count))
        let avgBR = Double(breathingRates.reduce(0, +)) / Double(max(1, breathingRates.count))

        return Summary(
            avgHeartRate: avgHR,
            avgBreathing: avgBR,
            minHeartRate: heartRates.min() ?? today.heartRate,
            maxHeartRate: heartRates.max() ?? today.heartRate,
            minBreathing: breathingRates.min() ?? today.breathingRate,
            maxBreathing: breathingRates.max() ?? today.breathingRate
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

        let historyLines = input.history
            .sorted { $0.timestamp < $1.timestamp }
            .suffix(30)
            .map { vital -> String in
                let day = iso.string(from: calendar.startOfDay(for: vital.timestamp))
                return "- \(day): HR \(vital.heartRate) bpm, BR \(vital.breathingRate) rpm"
            }
            .joined(separator: "\n")

        return """
You are an assistant for a health-tracking app. Provide supportive, non-alarmist insights.
Do NOT give medical diagnoses. Include a brief disclaimer like: 'Not medical advice.'

Today (\(iso.string(from: todayStart))):
- Heart rate: \(input.today.heartRate) bpm
- Breathing rate: \(input.today.breathingRate) rpm

History summary (last \(min(30, input.history.count)) days):
- Avg heart rate: \(String(format: "%.1f", summary.avgHeartRate)) bpm
- Avg breathing rate: \(String(format: "%.1f", summary.avgBreathing)) rpm
- Heart rate range: \(summary.minHeartRate)–\(summary.maxHeartRate) bpm
- Breathing rate range: \(summary.minBreathing)–\(summary.maxBreathing) rpm

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
