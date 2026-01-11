import SwiftUI
import SwiftData
import Charts

struct GeminiInsightScreen: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.44, green: 0.86, blue: 0.7).opacity(0.22), location: 0.0),
                    .init(color: Color(red: 0.70, green: 0.73, blue: 1.0).opacity(0.20), location: 0.45),
                    .init(color: Color("backgroundColor"), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                        .padding(.top, 18)

                    trendCharts
                        .padding(.top, 6)

                    GeminiInsightView(autoGenerateOnAppear: true, isFullScreen: true)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 44)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Insights")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 0.30, green: 0.92, blue: 0.74))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.75))
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
        }
    }

    private var trendCharts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your recent trends")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.12, green: 0.13, blue: 0.22).opacity(0.9))

            insightChartCard(
                title: "Heart Rate",
                subtitle: "Last 7 days",
                tint: Color(red: 0.36, green: 0.78, blue: 0.7)
            ) {
                Chart {
                    ForEach(heartRatePoints) { point in
                        if let bpm = point.value {
                            LineMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("BPM", bpm)
                            )
                            .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            .symbolSize(48)
                        }
                    }
                }
                .frame(height: 120)
                .chartXScale(domain: xDomain)
                .chartYScale(domain: 0...120)
                .chartXAxis {
                    AxisMarks(values: xDomain) { _ in
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.55))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.black.opacity(0.10))
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.62))
                    }
                }
            }

            insightChartCard(
                title: "Breathing Rate",
                subtitle: "Last 7 days",
                tint: Color(red: 0.70, green: 0.73, blue: 1.0)
            ) {
                Chart {
                    ForEach(breathingRatePoints) { point in
                        if let rpm = point.value {
                            LineMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("RPM", rpm)
                            )
                            .foregroundStyle(Color(red: 0.70, green: 0.73, blue: 1.0))
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            .symbolSize(48)
                        }
                    }
                }
                .frame(height: 120)
                .chartXScale(domain: xDomain)
                .chartYScale(domain: 8...24)
                .chartXAxis {
                    AxisMarks(values: xDomain) { _ in
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.55))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.black.opacity(0.10))
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.62))
                    }
                }
            }

            insightChartCard(
                title: "Sleep",
                subtitle: "Last 7 days",
                tint: Color(red: 0.36, green: 0.78, blue: 0.7)
            ) {
                Chart {
                    ForEach(sleepPoints) { point in
                        if let hours = point.value {
                            BarMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Hours", hours)
                            )
                            .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                            .cornerRadius(6)
                        }
                    }
                }
                .frame(height: 120)
                .chartXScale(domain: xDomain)
                .chartYScale(domain: 0...10)
                .chartXAxis {
                    AxisMarks(values: xDomain) { _ in
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.55))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.black.opacity(0.10))
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.62))
                    }
                }
            }
        }
    }

    private func insightChartCard<Content: View>(
        title: String,
        subtitle: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.88))
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.45))
                }

                Spacer()

                Circle()
                    .fill(tint.opacity(0.9))
                    .frame(width: 10, height: 10)
            }

            content()
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    private var xDomain: [String] {
        TrendAxis.lastNDays(count: 7).map { $0.label }
    }

    private var heartRatePoints: [TrendPoint<Int>] {
        let days = TrendAxis.lastNDays(count: 7)
        let byDateKey = latestVitalSignByDateKey(vitalSigns)
        return days.map { day in
            let key = dateKey(day.dayStart)
            let vital = byDateKey[key]
            return TrendPoint(dayLabel: day.label, value: vital?.heartRate)
        }
    }

    private var breathingRatePoints: [TrendPoint<Double>] {
        let days = TrendAxis.lastNDays(count: 7)
        let byDateKey = latestVitalSignByDateKey(vitalSigns)
        return days.map { day in
            let key = dateKey(day.dayStart)
            let vital = byDateKey[key]
            return TrendPoint(dayLabel: day.label, value: vital.map { Double($0.breathingRate) })
        }
    }

    private var sleepPoints: [TrendPoint<Double>] {
        let days = TrendAxis.lastNDays(count: 7)
        let byDateKey = latestVitalSignByDateKey(vitalSigns)
        return days.map { day in
            let key = dateKey(day.dayStart)
            let vital = byDateKey[key]
            return TrendPoint(dayLabel: day.label, value: vital?.sleepHours)
        }
    }

    private func latestVitalSignByDateKey(_ vitalSigns: [VitalSign]) -> [String: VitalSign] {
        // `vitalSigns` is already sorted newest-first; first per day wins.
        var result: [String: VitalSign] = [:]
        for vital in vitalSigns {
            let key = dateKey(vital.timestamp)
            if result[key] == nil {
                result[key] = vital
            }
        }
        return result
    }

    private func dateKey(_ date: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: start)
    }
}

#Preview {
    GeminiInsightScreen()
}
