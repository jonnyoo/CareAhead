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
                        .background(Color(red: 0.365, green: 0.384, blue: 0.659))
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Current Risk Score")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Low Risk")
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

    let points: [TrendPoint<Int>]
    let xDomain: [String]
    
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
                                Text("Avg HR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("81 BPM")
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
                                Text("Your typical HR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("75 BPM")
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
                        
                        Text("Your heart rate has been stable over the past week, averaging 81 BPM. This is within the normal range for adults. Keep maintaining your healthy lifestyle!")
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

struct RiskLevelDetailView: View {
    @Environment(\.dismiss) var dismiss

    let points: [TrendPoint<Double>]
    let xDomain: [String]
    
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
                                Text("Avg Risk")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("2.0 / 10")
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
                                Text("Status")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("Low Risk")
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
                        
                        Text("Your health risk level has remained low and stable over the past week, averaging 2.0 out of 10. This is excellent! Your vital signs are within healthy ranges. Continue your current lifestyle and health practices!")
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

struct BreathingRateDetailView: View {
    @Environment(\.dismiss) var dismiss

    let points: [TrendPoint<Double>]
    let xDomain: [String]
    
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
                                Text("Avg BR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("16 RPM")
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
                                Text("Your typical BR")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                                
                                Text("15 RPM")
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
                        
                        Text("Your breathing rate has been consistent over the past week, averaging 16 RPM. This is within the normal range for adults at rest. Keep up your good breathing habits!")
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

// MARK: - SwiftData-backed series

private extension TrendsView {
    var xDomain: [String] {
        TrendAxis.lastNDays(count: 7).map { $0.label }
    }

    var riskLevelPoints: [TrendPoint<Double>] {
        let days = TrendAxis.lastNDays(count: 7)
        // Hardcoded sample risk level data (0-10 scale, where 0 is low risk and 10 is high risk)
        let sampleRisk: [Double] = [2.1, 1.8, 2.5, 2.0, 1.9, 2.2, 1.7]
        return days.enumerated().map { index, day in
            let value = index < sampleRisk.count ? sampleRisk[index] : nil
            return TrendPoint(dayLabel: day.label, value: value)
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
