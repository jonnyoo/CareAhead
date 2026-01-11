import SwiftUI
import Charts

struct TrendsView: View {
    @State private var showingHeartRateDetail = false
    @State private var showingBreathingRateDetail = false
    @State private var showingSleepDetail = false
    
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
                            ForEach(heartRateData) { data in
                                LineMark(
                                    x: .value("Day", data.day),
                                    y: .value("BPM", data.steps)
                                )
                                .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                .symbolSize(60)
                            }
                        }
                        .frame(height: 175)
                        .chartYScale(domain: 0...120)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
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
                            ForEach(breathingRateData) { data in
                                LineMark(
                                    x: .value("Day", data.day),
                                    y: .value("RPM", data.rpm)
                                )
                                .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                .symbolSize(60)
                            }
                        }
                        .frame(height: 150)
                        .chartYScale(domain: 8...24)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
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
                        Text("Sleep")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                            .padding(.leading, 24)
                            .padding(.top, 25)
                        
                        // Bar Chart - 7 days
                        Chart {
                            ForEach(sleepData) { data in
                                BarMark(
                                    x: .value("Day", data.day),
                                    y: .value("Hours", data.hours)
                                )
                                .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                .cornerRadius(6)
                            }
                        }
                        .frame(height: 175)
                        .chartYScale(domain: 0...10)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
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
                    showingSleepDetail = true
                }
                Spacer(minLength: 100)
            }
            }
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showingHeartRateDetail) {
            HeartRateDetailView()
        }
        .sheet(isPresented: $showingBreathingRateDetail) {
            BreathingRateDetailView()
        }
        .sheet(isPresented: $showingSleepDetail) {
            SleepDetailView()
        }
    }
}

struct BreathingRateData: Identifiable {
    let id = UUID()
    let day: String
    let rpm: Double
}

let breathingRateData = [
    BreathingRateData(day: "Mon", rpm: 14),
    BreathingRateData(day: "Tue", rpm: 16),
    BreathingRateData(day: "Wed", rpm: 15),
    BreathingRateData(day: "Thu", rpm: 17),
    BreathingRateData(day: "Fri", rpm: 14),
    BreathingRateData(day: "Sat", rpm: 18),
    BreathingRateData(day: "Sun", rpm: 16)
]

struct HeartRateData: Identifiable {
    let id = UUID()
    let day: String
    let steps: Int
}

let heartRateData = [
    HeartRateData(day: "Mon", steps: 80),
    HeartRateData(day: "Tue", steps: 60),
    HeartRateData(day: "Wed", steps: 100),
    HeartRateData(day: "Thu", steps: 89),
    HeartRateData(day: "Fri", steps: 79),
    HeartRateData(day: "Sat", steps: 77),
    HeartRateData(day: "Sun", steps: 99)
]

struct SleepData: Identifiable {
    let id = UUID()
    let day: String
    let hours: Double
}

let sleepData = [
    SleepData(day: "Mon", hours: 7.5),
    SleepData(day: "Tue", hours: 6.8),
    SleepData(day: "Wed", hours: 8.2),
    SleepData(day: "Thu", hours: 7.0),
    SleepData(day: "Fri", hours: 7.8),
    SleepData(day: "Sat", hours: 6.5),
    SleepData(day: "Sun", hours: 8.5)
]

// Detail Views
struct HeartRateDetailView: View {
    @Environment(\.dismiss) var dismiss
    
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
                            ForEach(heartRateData) { data in
                                LineMark(
                                    x: .value("Day", data.day),
                                    y: .value("BPM", data.steps)
                                )
                                .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                .symbolSize(60)
                            }
                        }
                        .frame(height: 250)
                        .chartYScale(domain: 0...120)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
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
                            ForEach(breathingRateData) { data in
                                LineMark(
                                    x: .value("Day", data.day),
                                    y: .value("RPM", data.rpm)
                                )
                                .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                .symbolSize(60)
                            }
                        }
                        .frame(height: 250)
                        .chartYScale(domain: 8...24)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
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
                    .padding(.vertical, 24)
                    
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

struct SleepDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sleep")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.horizontal, 24)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
                        
                        VStack(spacing: 16) {
                            Chart {
                                ForEach(sleepData) { data in
                                    BarMark(
                                        x: .value("Day", data.day),
                                        y: .value("Hours", data.hours)
                                    )
                                    .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
                                    .cornerRadius(6)
                                }
                            }
                            .frame(height: 250)
                            .chartYScale(domain: 0...10)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
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
                        .padding(.vertical, 24)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.top, 20)
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
