import SwiftUI
import Charts
import SwiftData

struct TrendsView: View {
    @State private var showingRiskLevelDetail = false
    @State private var showingHeartRateDetail = false
    @State private var showingBreathingRateDetail = false
    @State private var showingStressDetail = false

    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]
    
    var body: some View {
        ZStack {
            // Background color
            Color("backgroundColor")
                .ignoresSafeArea()
            
            // Scrollable Content
            ScrollView {
                ZStack(alignment: .top) {
                    // Gradient Background - Scrolls with content
                    VStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 237)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.44, green: 0.86, blue: 0.7), location: 0.10),
                                        Gradient.Stop(color: Color(red: 0.7, green: 0.73, blue: 1).opacity(0.5), location: 0.47),
                                        Gradient.Stop(color: Color(red: 1, green: 0.74, blue: 0.29).opacity(0.25), location: 0.68),
                                        Gradient.Stop(color: Color(red: 1, green: 0.77, blue: 0.25).opacity(0), location: 0.84),
                                    ],
                                    startPoint: UnitPoint(x: 0.5, y: 0),
                                    endPoint: UnitPoint(x: 0.63, y: 0.96)
                                )
                            )
                            .opacity(0.3)
                        Spacer()
                    }
                    
                    
                VStack(alignment: .leading, spacing: 0) {
                // Title at top
                HStack {
                    Text("Your trends")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.28))
                    Spacer()
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                }
                .padding(.horizontal, 24)
                .padding(.top, 75)
                
                // Risk Level Card
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 366, height: 120)
                        .background(riskCardColor)
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Current Risk Score")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(riskCardTitle)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.trailing, 24)
                    }
                    .frame(width: 366, height: 120)
                }
                .onTapGesture {
                    showingRiskLevelDetail = true
                }
                .padding(.bottom, 10)
                .padding(.top, 20)
                
                // Card content
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 366, height: 260)
                        .background(.white)
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Heart Rate")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            .padding(.leading, 24)
                            .padding(.top, 40)
                    
                        // Line Chart - 7 days
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
                                    .symbolSize(60)
                                }
                            }
                        }
                        .frame(height: 175)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 0...120)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 0)
                    }
                    .frame(width: 366, height: 293, alignment: .topLeading)
                }
                .onTapGesture {
                    showingHeartRateDetail = true
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 366, height: 260)
                        .background(.white)
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Breathing Rate")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            .padding(.leading, 24)
                            .padding(.top, 40)
                        
                        // Line Chart - 7 days
                        Chart {
                            ForEach(breathingRatePoints) { point in
                                if let rpm = point.value {
                                    LineMark(
                                        x: .value("Day", point.dayLabel),
                                        y: .value("RPM", rpm)
                                    )
                                    .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol(Circle().strokeBorder(lineWidth: 2))
                                    .symbolSize(60)
                                }
                            }
                        }
                        .frame(height: 150)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 8...24)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 0)
                    }
                    .frame(width: 366, height: 293, alignment: .topLeading)
                }
                .onTapGesture {
                    showingBreathingRateDetail = true
                }
                .padding(.bottom, 10)
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 366, height: 293)
                        .background(.white)
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Stress")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            .padding(.leading, 24)
                            .padding(.top, 25)
                        
                        // Bar Chart - 7 days
                        Chart {
                            ForEach(stressPoints) { point in
                                if let level = point.value {
                                    BarMark(
                                        x: .value("Day", point.dayLabel),
                                        y: .value("Level", level)
                                    )
                                    .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .frame(height: 175)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 0...10)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                    .frame(width: 366, height: 293, alignment: .topLeading)
                }
                .onTapGesture {
                    showingStressDetail = true
                }
                Spacer(minLength: 100)
            }
            }
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showingRiskLevelDetail) {
            RiskLevelDetailView(points: riskLevelPoints, xDomain: xDomain)
        }
        .sheet(isPresented: $showingHeartRateDetail) {
            HeartRateDetailView(points: heartRatePoints, xDomain: xDomain)
        }
        .sheet(isPresented: $showingBreathingRateDetail) {
            BreathingRateDetailView(points: breathingRatePoints, xDomain: xDomain)
        }
        .sheet(isPresented: $showingStressDetail) {
            StressView(points: stressPoints, xDomain: xDomain)
        }
    }
}

enum TrendAxis {
    private static let calendar = Calendar.current
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE" // Mon/Tue/...
        return formatter
    }()

    static func lastNDays(count: Int, referenceDate: Date = Date()) -> [(label: String, dayStart: Date)] {
        guard count > 0 else { return [] }

        let startOfToday = calendar.startOfDay(for: referenceDate)
        return (0..<count).map { index in
            let daysAgo = (count - 1) - index
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) ?? startOfToday
            let label = calendar.isDate(date, inSameDayAs: startOfToday) ? "Today" : weekdayFormatter.string(from: date)
            return (label: label, dayStart: date)
        }
    }
}

// Detail Views
struct HeartRateDetailView: View {
    @Environment(\.dismiss) var dismiss

    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    let points: [TrendPoint<Int>]
    let xDomain: [String]

    private var todayHeartRate: Int? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return vitalSigns.first(where: { calendar.isDate($0.timestamp, inSameDayAs: start) })?.heartRate
    }

    private var baselineStats: TrendStats? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let values = vitalSigns
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: todayStart) }
            .prefix(60)
            .map { Double($0.heartRate) }
        return TrendStats.compute(values)
    }

    private var trendPrompt: String {
        let statsLine: String = {
            guard let s = baselineStats else { return "Baseline: (insufficient history)" }
            return "Baseline (last 30–60 days): avg \(Int(s.avg.rounded())) bpm, normal band \(Int(s.low.rounded()))–\(Int(s.high.rounded())) bpm"
        }()

        let todayLine = "Today HR: \(todayHeartRate.map(String.init) ?? "(no test)") bpm"
        let recent = points.compactMap { $0.value }
        let recentLine = recent.isEmpty ? "Recent (7 days): (no data)" : "Recent (7 days, oldest→newest): \(recent.map(String.init).joined(separator: ", "))"

        return """
You are a supportive assistant for a health-tracking app.
Do not diagnose. Do not claim certainty. Keep it to ONE short paragraph (2–4 sentences) + end with: Not medical advice.

Task: Describe the user's current heart-rate trend.
Focus on how today's value compares to their baseline average and normal band, and whether the recent 7-day series looks up/down/stable.
Include 1 numeric comparison (e.g. ~X bpm above avg) when possible.

\(todayLine)
\(statsLine)
\(recentLine)
"""
    }

    private var fallbackTrendText: String {
        let recent = points.compactMap { $0.value }.map { Double($0) }
        return baselineFallbackParagraph(
            metricName: "heart rate",
            today: todayHeartRate.map(Double.init),
            unit: "bpm",
            baseline: baselineStats,
            recent: recent,
            directionThreshold: 3
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing:0) {
                    Text("Heart Rate")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                    VStack(spacing: 16) {
                        Chart {
                            ForEach(points) { point in
                                if let bpm = point.value {
                                    LineMark(
                                        x: .value("Day", point.dayLabel),
                                        y: .value("BPM", bpm)
                                    )
                                    .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol(Circle().strokeBorder(lineWidth: 2))
                                    .symbolSize(60)
                                }
                            }
                        }
                        .frame(height: 250)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 0...120)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 0)
                    
                    HStack(spacing: 15) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Today HR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("\(todayHeartRate.map { "\($0)" } ?? "—") BPM")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 12)
                        }
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Avg HR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("\(baselineStats.map { "\(Int($0.avg.rounded()))" } ?? "—") BPM")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 15)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 25)
                    
                    Text("Trend")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)

                        VStack(alignment: .leading, spacing: 10) {
                            GeminiTrendParagraphView(prompt: trendPrompt, fallbackText: fallbackTrendText)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 25)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }
            }
        }
    }
}

struct RiskLevelDetailView: View {
    @Environment(\.dismiss) var dismiss

    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    let points: [TrendPoint<Double>]
    let xDomain: [String]

    private var todayRisk: Double? {
        points.first(where: { $0.dayLabel == "Today" })?.value
    }

    private var avgRisk: Double? {
        let values = points.compactMap { $0.value }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private var riskPrompt: String {
        let todayLine = "Today risk: \(todayRisk.map { String(format: "%.1f", $0) } ?? "(no data)") / 10"
        let avgLine = "Avg risk (7 days): \(avgRisk.map { String(format: "%.1f", $0) } ?? "(no data)") / 10"
        let series = points.compactMap { $0.value }
        let seriesLine = series.isEmpty ? "Recent (7 days): (no data)" : "Recent (7 days, oldest→newest): \(series.map { String(format: "%.1f", $0) }.joined(separator: ", "))"

        return """
You are a supportive assistant for a health-tracking app.
Do not diagnose. Do not claim certainty. Keep it to ONE short paragraph (2–4 sentences) + end with: Not medical advice.

Task: Describe the user's risk level trend.
Focus on whether it's stable/up/down over the last week, and keep wording calm.

\(todayLine)
\(avgLine)
\(seriesLine)
"""
    }

    private var fallbackTrendText: String {
        let recent = points.compactMap { $0.value }
        let dir = trendDirection(values: recent, threshold: 0.3)
        let trendSentence: String = {
            switch dir {
            case "up": return "Over the last week, your risk trend looks slightly up."
            case "down": return "Over the last week, your risk trend looks slightly down."
            default: return "Over the last week, your risk trend looks stable."
            }
        }()

        if let todayRisk, let avgRisk {
            let delta = todayRisk - avgRisk
            return "Today: \(String(format: "%.1f", todayRisk))/10. Weekly avg: \(String(format: "%.1f", avgRisk))/10 (\(formatSigned(delta, unit: "/10", decimals: 1)) vs avg). \(trendSentence)"
        }
        return "Run today’s video test to compute your risk score trend. \(trendSentence)"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing:0) {
                    Text("Risk Level")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    VStack(spacing: 16) {
                        Chart {
                            ForEach(points) { point in
                                if let risk = point.value {
                                    LineMark(
                                        x: .value("Day", point.dayLabel),
                                        y: .value("Risk", risk)
                                    )
                                    .foregroundStyle(Color(red: 0.365, green: 0.384, blue: 0.659))
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol(Circle().strokeBorder(lineWidth: 2))
                                    .symbolSize(60)
                                }
                            }
                        }
                        .frame(height: 250)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 0...10)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 0)
                    
                    HStack(spacing: 15) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Today")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("\(todayRisk.map { String(format: "%.1f", $0) } ?? "—") / 10")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 12)
                        }
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Avg")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("\(avgRisk.map { String(format: "%.1f", $0) } ?? "—") / 10")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 15)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 25)
                    
                    Text("Trend")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            GeminiTrendParagraphView(prompt: riskPrompt, fallbackText: fallbackTrendText)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 25)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }
            }
        }
    }
}

struct BreathingRateDetailView: View {
    @Environment(\.dismiss) var dismiss

    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    let points: [TrendPoint<Double>]
    let xDomain: [String]

    private var todayBreathing: Int? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return vitalSigns.first(where: { calendar.isDate($0.timestamp, inSameDayAs: start) })?.breathingRate
    }

    private var baselineStats: TrendStats? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let values = vitalSigns
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: todayStart) }
            .prefix(60)
            .map { Double($0.breathingRate) }
        return TrendStats.compute(values)
    }

    private var trendPrompt: String {
        let statsLine: String = {
            guard let s = baselineStats else { return "Baseline: (insufficient history)" }
            return "Baseline (last 30–60 days): avg \(Int(s.avg.rounded())) rpm, normal band \(Int(s.low.rounded()))–\(Int(s.high.rounded())) rpm"
        }()

        let todayLine = "Today BR: \(todayBreathing.map(String.init) ?? "(no test)") rpm"
        let recent = points.compactMap { $0.value }.map { Int($0.rounded()) }
        let recentLine = recent.isEmpty ? "Recent (7 days): (no data)" : "Recent (7 days, oldest→newest): \(recent.map(String.init).joined(separator: ", "))"

        return """
You are a supportive assistant for a health-tracking app.
Do not diagnose. Do not claim certainty. Keep it to ONE short paragraph (2–4 sentences) + end with: Not medical advice.

Task: Describe the user's current breathing-rate trend.
Focus on how today's value compares to their baseline average and normal band, and whether the recent 7-day series looks up/down/stable.
Include 1 numeric comparison (e.g. ~X rpm above avg) when possible.

\(todayLine)
\(statsLine)
\(recentLine)
"""
    }

    private var fallbackTrendText: String {
        let recent = points.compactMap { $0.value }
        return baselineFallbackParagraph(
            metricName: "breathing rate",
            today: todayBreathing.map(Double.init),
            unit: "rpm",
            baseline: baselineStats,
            recent: recent,
            directionThreshold: 1
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Breathing Rate")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                    VStack(spacing: 16) {
                        Chart {
                            ForEach(points) { point in
                                if let rpm = point.value {
                                    LineMark(
                                        x: .value("Day", point.dayLabel),
                                        y: .value("RPM", rpm)
                                    )
                                    .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol(Circle().strokeBorder(lineWidth: 2))
                                    .symbolSize(60)
                                }
                            }
                        }
                        .frame(height: 250)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 8...24)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 0)
                    
                    HStack(spacing: 15) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Today BR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("\(todayBreathing.map { "\($0)" } ?? "—") RPM")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 12)
                        }
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Avg BR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("\(baselineStats.map { "\(Int($0.avg.rounded()))" } ?? "—") RPM")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 15)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 25)
                    
                    Text("Trend")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            GeminiTrendParagraphView(prompt: trendPrompt, fallbackText: fallbackTrendText)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 25)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .padding(.top, 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }
            }
        }
    }
}

struct StressView: View {
    @Environment(\.dismiss) var dismiss

    let points: [TrendPoint<Double>]
    let xDomain: [String]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Stress")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)

                    VStack(spacing: 16) {
                        Chart {
                            ForEach(points) { point in
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
                        .frame(height: 250)
                        .chartXScale(domain: xDomain)
                        .chartYScale(domain: 0...10)
                        .chartXAxis {
                            AxisMarks(values: xDomain) { _ in
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.22))
                                AxisValueLabel()
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.72))
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 0)

                    HStack(spacing: 15) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Avg Stress")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("4.2 / 10")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 12)
                        }
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 175, height: 80)
                                .background(Color(red: 0.87, green: 0.94, blue: 0.93))
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Typical Stress")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("4.0 / 10")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            }
                            .padding(.leading, 15)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 25)
                    
                    Text("Trend")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                    
                    ZStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        
                        Text("Your stress levels have been relatively low over the past week, averaging 4.2 out of 10. This indicates good stress management. Continue practicing your stress-relief techniques to maintain this healthy balance!")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 25)
                            .padding(.top, 25)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Spacer()
                }
                .padding(.top, 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }
            }
        }
    }
}

#Preview {
    TrendsView()
}

struct TrendPoint<Value>: Identifiable {
    let dayLabel: String
    let value: Value?

    var id: String { dayLabel }
}

fileprivate struct TrendStats {
    let avg: Double
    let low: Double
    let high: Double
    let stdDev: Double

    static func compute(_ values: [Double]) -> TrendStats? {
        guard !values.isEmpty else { return nil }
        let avg = values.reduce(0, +) / Double(values.count)
        let std = stdDev(values, mean: avg)
        let band = normalBand(values)
        return TrendStats(avg: avg, low: band.0, high: band.1, stdDev: std)
    }

    private static func stdDev(_ values: [Double], mean: Double) -> Double {
        guard values.count >= 2 else { return 0 }
        let variance = values
            .map { ($0 - mean) * ($0 - mean) }
            .reduce(0, +) / Double(values.count - 1)
        return sqrt(variance)
    }

    private static func normalBand(_ values: [Double]) -> (Double, Double) {
        let sorted = values.sorted()
        if sorted.count >= 10 {
            return (percentile(sorted, p: 0.15), percentile(sorted, p: 0.85))
        }
        return (sorted.first ?? 0, sorted.last ?? 0)
    }

    private static func percentile(_ sorted: [Double], p: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        let clamped = min(1, max(0, p))
        let idx = (Double(sorted.count - 1) * clamped)
        let lower = Int(floor(idx))
        let upper = Int(ceil(idx))
        if lower == upper { return sorted[lower] }
        let weight = idx - Double(lower)
        return sorted[lower] * (1 - weight) + sorted[upper] * weight
    }
}

fileprivate func trendDirection(values: [Double], threshold: Double) -> String {
    guard values.count >= 2, let first = values.first, let last = values.last else { return "stable" }
    let delta = last - first
    if delta > threshold { return "up" }
    if delta < -threshold { return "down" }
    return "stable"
}

fileprivate func formatSigned(_ value: Double, unit: String, decimals: Int = 0) -> String {
    let sign = value >= 0 ? "+" : "−"
    let absVal = abs(value)
    let formatted: String
    if decimals == 0 {
        formatted = String(Int(absVal.rounded()))
    } else {
        formatted = String(format: "%0.*f", decimals, absVal)
    }
    return "\(sign)\(formatted) \(unit)"
}

fileprivate func baselineFallbackParagraph(
    metricName: String,
    today: Double?,
    unit: String,
    baseline: TrendStats?,
    recent: [Double],
    directionThreshold: Double
) -> String {
    let dir = trendDirection(values: recent, threshold: directionThreshold)
    let trendSentence: String = {
        switch dir {
        case "up": return "Over the last week, your \(metricName) trend looks slightly up."
        case "down": return "Over the last week, your \(metricName) trend looks slightly down."
        default: return "Over the last week, your \(metricName) trend looks stable."
        }
    }()

    guard let today, let baseline else {
        if let today {
            return "Today: \(Int(today.rounded())) \(unit). \(trendSentence)"
        }
        return "Run today’s video test to see how your \(metricName) compares to your baseline. \(trendSentence)"
    }

    let delta = today - baseline.avg
    let within = (today >= baseline.low && today <= baseline.high)
    let withinText = within ? "within" : "outside"
    return "Today: \(Int(today.rounded())) \(unit). Baseline avg: \(Int(baseline.avg.rounded())) \(unit) (normal \(Int(baseline.low.rounded()))–\(Int(baseline.high.rounded()))). That’s \(formatSigned(delta, unit: unit)) vs your average and \(withinText) your normal band. \(trendSentence)"
}

// MARK: - SwiftData-backed series

private extension TrendsView {
    var todayVital: VitalSign? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return vitalSigns.first(where: { calendar.isDate($0.timestamp, inSameDayAs: start) })
    }

    var baselineHeartRateStats: TrendStats? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let values = vitalSigns
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: todayStart) }
            .prefix(60)
            .map { Double($0.heartRate) }
        return TrendStats.compute(values)
    }

    var baselineBreathingStats: TrendStats? {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let values = vitalSigns
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: todayStart) }
            .prefix(60)
            .map { Double($0.breathingRate) }
        return TrendStats.compute(values)
    }

    func penalty(value: Double, low: Double, high: Double, scale: Double) -> Double {
        if value < low {
            return min(99, ((low - value) / max(1, scale)) * 35)
        }
        if value > high {
            return min(99, ((value - high) / max(1, scale)) * 35)
        }
        return 6
    }

    var riskScore: Int? {
        guard let today = todayVital,
              let hr = baselineHeartRateStats,
              let br = baselineBreathingStats
        else { return nil }

        let hrPenalty = penalty(value: Double(today.heartRate), low: hr.low, high: hr.high, scale: max(6, hr.stdDev))
        let brPenalty = penalty(value: Double(today.breathingRate), low: br.low, high: br.high, scale: max(2, br.stdDev))
        let combined = 1 + Int((hrPenalty * 0.6 + brPenalty * 0.4).rounded())
        return min(100, max(1, combined))
    }

    var riskCardTitle: String {
        guard let score = riskScore else { return "No test" }
        switch score {
        case 1...25: return "Low Risk"
        case 26...60: return "Moderate"
        default: return "Elevated"
        }
    }

    var riskCardColor: Color {
        guard let score = riskScore else { return Color(red: 0.365, green: 0.384, blue: 0.659).opacity(0.7) }
        switch score {
        case 1...25:
            return Color(red: 0.28, green: 0.72, blue: 0.55)
        case 26...60:
            return Color(red: 0.93, green: 0.73, blue: 0.18)
        default:
            return Color(red: 0.92, green: 0.38, blue: 0.42)
        }
    }

    var xDomain: [String] {
        TrendAxis.lastNDays(count: 7).map { $0.label }
    }

    var riskLevelPoints: [TrendPoint<Double>] {
        let days = TrendAxis.lastNDays(count: 7)
        guard let hr = baselineHeartRateStats, let br = baselineBreathingStats else {
            return days.map { TrendPoint(dayLabel: $0.label, value: nil) }
        }

        let byDateKey = Self.latestVitalSignByDateKey(vitalSigns)
        return days.map { day in
            let key = Self.dateKey(day.dayStart)
            guard let vital = byDateKey[key] else {
                return TrendPoint(dayLabel: day.label, value: nil)
            }

            let hrPenalty = penalty(value: Double(vital.heartRate), low: hr.low, high: hr.high, scale: max(6, hr.stdDev))
            let brPenalty = penalty(value: Double(vital.breathingRate), low: br.low, high: br.high, scale: max(2, br.stdDev))
            let combined = 1 + Int((hrPenalty * 0.6 + brPenalty * 0.4).rounded())
            let score100 = min(100, max(1, combined))
            let score10 = Double(score100) / 10.0
            return TrendPoint(dayLabel: day.label, value: score10)
        }
    }

    var heartRatePoints: [TrendPoint<Int>] {
        let days = TrendAxis.lastNDays(count: 7)
        let byDateKey = Self.latestVitalSignByDateKey(vitalSigns)
        return days.map { day in
            let key = Self.dateKey(day.dayStart)
            let vital = byDateKey[key]
            return TrendPoint(dayLabel: day.label, value: vital?.heartRate)
        }
    }

    var breathingRatePoints: [TrendPoint<Double>] {
        let days = TrendAxis.lastNDays(count: 7)
        let byDateKey = Self.latestVitalSignByDateKey(vitalSigns)
        return days.map { day in
            let key = Self.dateKey(day.dayStart)
            let vital = byDateKey[key]
            return TrendPoint(dayLabel: day.label, value: vital.map { Double($0.breathingRate) })
        }
    }

    var stressPoints: [TrendPoint<Double>] {
        let days = TrendAxis.lastNDays(count: 7)
        // Hardcoded sample stress level data (0-10 scale)
        let sampleStress: [Double] = [3.5, 4.2, 5.1, 3.8, 4.5, 4.0, 4.3]
        return days.enumerated().map { index, day in
            let value = index < sampleStress.count ? sampleStress[index] : nil
            return TrendPoint(dayLabel: day.label, value: value)
        }
    }

    static func latestVitalSignByDateKey(_ vitalSigns: [VitalSign]) -> [String: VitalSign] {
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

    static func dateKey(_ date: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: start)
    }
}
