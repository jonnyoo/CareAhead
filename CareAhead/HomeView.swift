import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: Int

    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]
    
    var body: some View {
        ZStack {
            // Background color
            Color("backgroundColor")
                .ignoresSafeArea()
            
            GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 403, height: 237)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.44, green: 0.86, blue: 0.7), location: 0.10),
                            Gradient.Stop(color: Color(red: 0.7, green: 0.73, blue: 1).opacity(0.9), location: 0.47),
                            Gradient.Stop(color: Color(red: 1, green: 0.74, blue: 0.29).opacity(0.55), location: 0.68),
                            Gradient.Stop(color: Color(red: 1, green: 0.77, blue: 0.25).opacity(0), location: 0.84),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.63, y: 0.96)
                    )
                    .opacity(0.3)
                )
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Afternoon,")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.65))
                            Text("Olivia")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                        }
                        
                        Spacer()
                        
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.5, green: 0.65, blue: 0.95))
                                .frame(width: 32, height: 32)
                            
                            Image("Profile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Looking Good Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.45, green: 0.48, blue: 0.75))
                            .frame(height: 200)
                        
                        HStack(alignment: .bottom, spacing: 0) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .center, spacing: 10) {
                                    Text(encouragementTitle)
                                        .font(.system(size: 35, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer().frame(width: 30)
                                    
                                    
                                    ZStack() {
                                        RoundedRectangle(cornerRadius:7)
                                            .fill(riskScoreColor)
                                            .frame(width: 70, height: 30
                                            )
                                        
                                        Text(riskScoreText)
                                            .font(.system(size: 16, weight:.semibold))
                                            .foregroundColor(Color(red: 0.2118, green: 0.4078, blue: 0.2431))

                                    }
                                    .offset(y: 2)
                                    
                                }
                            
                                
                                Text(overviewBlurb)
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white.opacity(0.95))
                                    .lineSpacing(4)
                            }
                            .padding(.leading, 28)
                            .padding(.bottom, 28)
                            
                            Spacer(minLength: 0)
                        }
                        
                        // Happy Face positioned absolutely in bottom-right corner
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image("happy")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 125, height: 125)
                            }
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal)

                    
                    // Your Trends Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Your Trends")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                            
                            Spacer()
                            
                            Button(action: {
                                selectedTab = 3
                            }) {
                                Text("See all")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Health Metrics Scroll View
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Heart Rate Card
                                HealthMetricCard(
                                    title: "Heart Rate",
                                    description: heartRateCardText,
                                    barColors: [
                                        Color(red: 0.4, green: 0.8, blue: 0.7),
                                        Color(red: 0.5, green: 0.85, blue: 0.75),
                                        Color(red: 0.5, green: 0.85, blue: 0.75),
                                        Color(red: 0.5, green: 0.85, blue: 0.75)
                                    ],
                                    barHeights: [120, 90, 85, 100]
                                )
                                
                                // Breathing Card
                                HealthMetricCard(
                                    title: "Breathing",
                                    description: breathingCardText,
                                    barColors: [
                                        Color(red: 0.6, green: 0.75, blue: 0.95),
                                        Color(red: 0.65, green: 0.78, blue: 0.98),
                                        Color(red: 0.65, green: 0.78, blue: 0.98),
                                        Color(red: 0.6, green: 0.75, blue: 0.95)
                                    ],
                                    barHeights: [95, 110, 100, 105]
                                )
                                
                                // Stress Card
                                HealthMetricCard(
                                    title: "Stress",
                                    description: "Stress is down\n15% vs last week.",
                                    barColors: [
                                        Color(red: 0.95, green: 0.7, blue: 0.6),
                                        Color(red: 0.92, green: 0.65, blue: 0.55),
                                        Color(red: 0.92, green: 0.65, blue: 0.55),
                                        Color(red: 0.95, green: 0.7, blue: 0.6)
                                    ],
                                    barHeights: [70, 85, 60, 75]
                                )
                            }
                            .padding(.horizontal)
                        }
                }
                    // Current Suggestions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Suggestions")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            SuggestionCard(
                                title: suggestionLargeTitle,
                                description: suggestionLargeDescription,
                                icon: suggestionLargeIcon,
                                cardNumber: 1,
                                isLarge: true
                            )
                            
                            VStack(spacing: 12) {
                                SuggestionCard(
                                    title: suggestionSmall1Title,
                                    description: suggestionSmall1Description,
                                    icon: suggestionSmall1Icon,
                                    cardNumber: 2
                                )
                            
                                SuggestionCard(
                                    title: suggestionSmall2Title,
                                    description: suggestionSmall2Description,
                                    icon: suggestionSmall2Icon,
                                    cardNumber: 3,
                                    isWide: true
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    Text("CareAhead is not a replacement for medical professionals, but rather a basic way to monitor your own health.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 80)

                }
            }
        }
    }
}

// MARK: - Home computations

private extension HomeView {
    struct Stats {
        let avg: Double
        let low: Double
        let high: Double
        let stdDev: Double
    }

    var todayVital: VitalSign? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return vitalSigns.first(where: { calendar.isDate($0.timestamp, inSameDayAs: start) })
    }

    var comparisonVitals: [VitalSign] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        return vitalSigns
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: todayStart) }
            .prefix(60)
            .map { $0 }
    }

    var heartRateStats: Stats? {
        let values = comparisonVitals.map { Double($0.heartRate) }
        return stats(values)
    }

    var breathingStats: Stats? {
        let values = comparisonVitals.map { Double($0.breathingRate) }
        return stats(values)
    }

    var encouragementTitle: String {
        // Short, encouraging phrases that can rotate.
        if todayVital == nil {
            return "Quick check-in?"
        }

        let phrasesLow = ["Looking great!", "On track!", "Nice work!", "All good!"]
        let phrasesMid = ["Staying steady", "Doing okay!", "Keep it up", "Nice trend!"]
        let phrasesHigh = ["Let’s reset", "Take it easy", "Small steps", "Breathe & reset"]

        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0)
        if riskScore <= 25 {
            return phrasesLow[abs(dayIndex) % phrasesLow.count]
        } else if riskScore <= 60 {
            return phrasesMid[abs(dayIndex) % phrasesMid.count]
        } else {
            return phrasesHigh[abs(dayIndex) % phrasesHigh.count]
        }
    }

    var overviewBlurb: String {
        if todayVital == nil {
            return "Do today’s video test\nto generate insights\nfrom your past data."
        }
        return "Your health trends align\nwith your past data!"
    }

    var riskScore: Int {
        guard let today = todayVital, let hr = heartRateStats, let br = breathingStats else { return 0 }

        // Score is driven by how far today is from the user’s normal band.
        // 1 = very low risk, 100 = very high risk.
        let hrPenalty = penalty(value: Double(today.heartRate), low: hr.low, high: hr.high, scale: max(6, hr.stdDev))
        let brPenalty = penalty(value: Double(today.breathingRate), low: br.low, high: br.high, scale: max(2, br.stdDev))
        let combined = 1 + Int((hrPenalty * 0.6 + brPenalty * 0.4).rounded())
        return min(100, max(1, combined))
    }

    var riskScoreText: String {
        todayVital == nil ? "RS: —" : "RS: \(riskScore)"
    }

    var riskScoreColor: Color {
        guard todayVital != nil else {
            return Color.white.opacity(0.35)
        }
        switch riskScore {
        case 1...25:
            return Color(red: 0.52, green: 0.91, blue: 0.58)
        case 26...60:
            return Color(red: 1.0, green: 0.78, blue: 0.25)
        default:
            return Color(red: 0.96, green: 0.42, blue: 0.45)
        }
    }

    var heartRateCardText: String {
        guard let hr = heartRateStats else {
            return "Avg: —\nNormal: —\nRun a few tests\nto build baseline."
        }
        let stableLine = stabilityLine(current: todayVital.map { Double($0.heartRate) }, stats: hr)
        return "Avg: \(Int(hr.avg.rounded())) bpm\nNormal: \(Int(hr.low.rounded()))–\(Int(hr.high.rounded()))\n\(stableLine)"
    }

    var breathingCardText: String {
        guard let br = breathingStats else {
            return "Avg: —\nNormal: —\nRun a few tests\nto build baseline."
        }
        let stableLine = stabilityLine(current: todayVital.map { Double($0.breathingRate) }, stats: br)
        return "Avg: \(Int(br.avg.rounded())) rpm\nNormal: \(Int(br.low.rounded()))–\(Int(br.high.rounded()))\n\(stableLine)"
    }

    var suggestionLargeTitle: String {
        if todayVital == nil { return "Get today’s reading" }
        if riskScore >= 60 { return "Reset & recover" }
        return "Keep your rhythm"
    }

    var suggestionLargeDescription: String {
        // Medium-length suggestion.
        guard let today = todayVital else {
            return "Run the video test once today to personalize your baseline and unlock a detailed insight summary."
        }
        if let hr = heartRateStats, Double(today.heartRate) > hr.high {
            return "Today’s heart rate is a bit above your normal band. Try a 5–10 minute wind-down: slow breathing, water, and a short break from screens."
        }
        if let br = breathingStats, Double(today.breathingRate) > br.high {
            return "Your breathing rate is a bit higher than your usual. Try a 3–5 minute breathing reset (inhale 4s, exhale 6s) and re-test later."
        }
        return "Your breathing and heart rate look consistent with your baseline. Keep your routine steady and re-test around the same time tomorrow."
    }

    var suggestionLargeIcon: String { "sparkles" }

    // Two short suggestions.
    var suggestionSmall1Title: String { "Hydration" }
    var suggestionSmall1Description: String { "Drink a full glass of water" }
    var suggestionSmall1Icon: String { "drop.fill" }

    var suggestionSmall2Title: String { "Movement" }
    var suggestionSmall2Description: String { "10-minute easy walk" }
    var suggestionSmall2Icon: String { "figure.walk" }

    func stabilityLine(current: Double?, stats: Stats) -> String {
        guard let current else {
            return "Normal range."
        }
        let within = (current >= stats.low && current <= stats.high)
        let stable = stats.stdDev <= 8

        if within && stable {
            return "Stable. Normal range."
        }
        if within {
            return "Normal range."
        }
        return "Outside normal range."
    }

    func stats(_ values: [Double]) -> Stats? {
        guard !values.isEmpty else { return nil }
        let avg = values.reduce(0, +) / Double(values.count)
        let std = stdDev(values, mean: avg)
        let (low, high) = normalBand(values)
        return Stats(avg: avg, low: low, high: high, stdDev: std)
    }

    func stdDev(_ values: [Double], mean: Double) -> Double {
        guard values.count >= 2 else { return 0 }
        let variance = values
            .map { ($0 - mean) * ($0 - mean) }
            .reduce(0, +) / Double(values.count - 1)
        return sqrt(variance)
    }

    func normalBand(_ values: [Double]) -> (Double, Double) {
        let sorted = values.sorted()
        if sorted.count >= 10 {
            let low = percentile(sorted, p: 0.15)
            let high = percentile(sorted, p: 0.85)
            return (low, high)
        }
        return (sorted.first ?? 0, sorted.last ?? 0)
    }

    func percentile(_ sorted: [Double], p: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        let clamped = min(1, max(0, p))
        let idx = (Double(sorted.count - 1) * clamped)
        let lower = Int(floor(idx))
        let upper = Int(ceil(idx))
        if lower == upper { return sorted[lower] }
        let weight = idx - Double(lower)
        return sorted[lower] * (1 - weight) + sorted[upper] * weight
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
}

struct HealthMetricCard: View {
    let title: String
    let description: String
    let barColors: [Color]
    let barHeights: [Double]
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.88, green: 0.88, blue: 0.95).opacity(0.6))
                .frame(height: 220)
                .frame(minWidth: 280)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .padding(.top, 20)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.45))
                    
                    Text(description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.5))
                        .lineSpacing(2)
                }
                .padding(.leading, 28)
                .padding(.bottom, 28)
                
                Spacer()
                
                // Bar Chart
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<barHeights.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(barColors[index])
                            .frame(width: 36, height: barHeights[index])
                    }
                }
                .padding(.trailing, 28)
                .padding(.bottom, 28)
            }
            

        }
    }
}

struct SuggestionCard: View {
    let title: String
    let description: String
    let icon: String
    let cardNumber: Int
    var isWide: Bool = false
    var isLarge: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient/Color background
            if isLarge {
                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: Color(red: 0.85, green: 0.87, blue: 0.97), location: 0),
                        Gradient.Stop(color: Color.white, location: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.9, blue: 0.96).opacity(0.8),
                        Color(red: 0.85, green: 0.88, blue: 0.98).opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            if !isLarge {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: isWide ? 140 : 180)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: isWide ? 24 : 22, weight: .bold))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75).opacity(0.8))
                    .lineSpacing(2)
            }
            .padding(20)
            
            // Card number at bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("\(cardNumber)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75).opacity(0.15))
                        .padding(.trailing, 5)
                        .padding(.bottom, 0)
                }
            }
        }
        .frame(height: isLarge ? 333 : (isWide ? 140 : 180))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
