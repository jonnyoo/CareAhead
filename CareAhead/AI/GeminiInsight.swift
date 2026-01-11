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
                return "- Sleep: \(String(format: "%.1f", hours)) hours"
            }
            return "- Sleep: (no data)"
        }()

        let sleepSummaryLines: String = {
            guard let avg = summary.avgSleepHours else { return "" }
            let minLine: String
            let maxLine: String
            if let min = summary.minSleepHours, let max = summary.maxSleepHours {
                minLine = "- Sleep range: \(String(format: "%.1f", min))–\(String(format: "%.1f", max)) hours"
                maxLine = ""
            } else {
                minLine = ""
                maxLine = ""
            }

            return """
- Avg sleep: \(String(format: "%.1f", avg)) hours
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
                    return "- \(day): HR \(vital.heartRate) bpm, BR \(vital.breathingRate) rpm, Sleep \(String(format: "%.1f", sleep)) h"
                }
                return "- \(day): HR \(vital.heartRate) bpm, BR \(vital.breathingRate) rpm"
            }
            .joined(separator: "\n")

        return """
    You are an assistant for a health-tracking app. Provide supportive, non-alarmist insights.
    Do NOT give medical diagnoses. Do NOT claim certainty. Include a brief disclaimer: 'Not medical advice.'
    Write a LONG, detailed analysis (aim for 800–1200 words). Use clear markdown headings and bullet lists.

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

Output format (markdown):

## Today’s Insights
- A detailed narrative summary of today’s HR/BR/Sleep together (not just bullets).
- Call out what seems “in range” vs “notable” *relative to their own baseline*, using the summary numbers.

## Compared to your baseline
- Quantify differences vs averages (e.g., “~X bpm above your avg”).
- Discuss whether the difference is likely meaningful or could be normal daily variation.

## Trend & variability (last 7–30 days)
- Describe directionality (up/down/stable) and volatility.
- If the history suggests irregularity, describe it gently and mention benign causes (sleep, stress, caffeine, posture, time of day).

## Sleep context (if present)
- Explain how sleep duration could relate to resting HR/BR (correlation, not causation).
- If sleep is missing today, mention that and still use historical sleep for context.

## Data quality & confidence
- Mention that camera-based estimates can vary; note any reasons accuracy could be affected (movement, lighting, face detection).
- State a confidence level (low/medium/high) and why.

## Practical plan for today
- 3–6 specific, gentle, actionable suggestions (hydration, stress reset, breathing drill, bedtime routine), no medical claims.

## What to watch tomorrow
- 2–4 simple things to track (sleep, time of test, hydration, exercise) that could explain changes.

End with: 'Not medical advice.'
"""
    }
}
