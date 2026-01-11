import SwiftUI
import Charts

// MARK: - Screen

struct SharedView: View {

    // Mock data using asset names
    private let updates: [UpdateCard] = [
        .init(avatarAsset: "Amy", name: "Amy Z.", time: "yesterday",
              message: "Heart rate has been\nhigher than usual for\nthe past week"),
        .init(avatarAsset: "Tom", name: "Tom Z.", time: "yesterday",
              message: "Heart rate has been\nhigher than usual for\nthe past week")
    ]

    private let contacts: [ShareContact] = [
        .init(avatarAsset: "Amy", name: "Amy Z.", relation: "Mother", moodAsset: "greenHappy"),
        .init(avatarAsset: "Tom", name: "Tom Z.", relation: "Father", moodAsset: "sadface"),
        .init(avatarAsset: "Raymond", name: "Raymond Z.", relation: "Brother", moodAsset: "neutralFace")
    ]

    @State private var selectedTab: Tab = .sharing
    @State private var selectedContact: ShareContact?
    @State private var showSheet = false

    enum Tab: CaseIterable {
        case home, sharing, vitals, explore

        var sf: String {
            switch self {
            case .home: return "house"
            case .sharing: return "person.2"
            case .vitals: return "waveform.path.ecg"
            case .explore: return "map"
            }
        }
    }

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Sharing")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color(hex: 0x1E2447))
                    .padding(.top, 10)

                // Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(updates) { item in
                            UpdateCardView(item: item)
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.leading, 23)
                }
                .frame(height: 170)
                .padding(.horizontal, -22)

                // Contacts
                VStack(spacing: 14) {
                    ForEach(contacts) { contact in
                        Button(action: {
                            selectedContact = contact
                            showSheet = true
                        }) {
                            ContactRowView(contact: contact)
                        }
                    }
                }

                Spacer(minLength: 0)

            }
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
        }
        .sheet(isPresented: $showSheet) {
            if let _ = selectedContact {
                SharedHeartRateDetailView(points: mockHeartRatePoints, xDomain: mockXDomain)
            }
        }
    }

    private var background: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: 0xCEECE1), location: 0.00),
                .init(color: Color(hex: 0xE6EBF7), location: 0.55),
                .init(color: Color(hex: 0xF3F4F8), location: 1.00),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var mockXDomain: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Today"]
    }

    private var mockHeartRatePoints: [SharedTrendPoint<Int>] {
        [
            SharedTrendPoint(dayLabel: "Mon", value: 72),
            SharedTrendPoint(dayLabel: "Tue", value: 75),
            SharedTrendPoint(dayLabel: "Wed", value: 68),
            SharedTrendPoint(dayLabel: "Thu", value: 80),
            SharedTrendPoint(dayLabel: "Fri", value: 76),
            SharedTrendPoint(dayLabel: "Sat", value: 74),
            SharedTrendPoint(dayLabel: "Today", value: 78)
        ]
    }

    private var mockBreathingRatePoints: [SharedTrendPoint<Double>] {
        [
            SharedTrendPoint(dayLabel: "Mon", value: 16.0),
            SharedTrendPoint(dayLabel: "Tue", value: 15.5),
            SharedTrendPoint(dayLabel: "Wed", value: 17.0),
            SharedTrendPoint(dayLabel: "Thu", value: 14.8),
            SharedTrendPoint(dayLabel: "Fri", value: 16.2),
            SharedTrendPoint(dayLabel: "Sat", value: 15.8),
            SharedTrendPoint(dayLabel: "Today", value: 16.5)
        ]
    }
}

// MARK: - Models

struct UpdateCard: Identifiable {
    let id = UUID()
    let avatarAsset: String
    let name: String
    let time: String
    let message: String
}

struct ShareContact: Identifiable {
    let id = UUID()
    let avatarAsset: String
    let name: String
    let relation: String
    let moodAsset: String
}

// MARK: - Components

private struct UpdateCardView: View {
    let item: UpdateCard

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(hex: 0x5E62A3))
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 10)

            // Watermark (your mock has a big faint heart/shape).
            // If your exported watermark SVG is named "Image", this will use it.
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .opacity(0.22)
                .offset(x: 20, y: 22)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    AssetIcon(name: item.avatarAsset)
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text(item.time)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Spacer()
                }

                Text(item.message)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(2)

                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .frame(width: 300, height: 160)
    }
}

private struct ContactRowView: View {
    let contact: ShareContact

    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)

            // Big mood face (cropped off the right edge like your mock)
            Image(contact.moodAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .offset(y: 20)
                .offset(x: 15)

            HStack(spacing: 14) {
                AssetIcon(name: contact.avatarAsset)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.88))

                    Text(contact.relation)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.55))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct AssetIcon: View {
    let name: String

    var body: some View {
        Image(name)
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
            .clipShape(Circle())
            .accessibilityLabel(Text(name))
    }
}

// MARK: - Utilities

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

#Preview {
    SharedView()
        .preferredColorScheme(.light)
}

// MARK: - Detail Views

private struct SharedHeartRateDetailView: View {
    @Environment(\.dismiss) var dismiss

    let points: [SharedTrendPoint<Int>]
    let xDomain: [String]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Heart Rate")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                        .padding(.top, 30)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
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
                .padding(.vertical, 24)
                
                Spacer()
            }
        }
    }
}

private struct SharedBreathingRateDetailView: View {
    @Environment(\.dismiss) var dismiss

    let points: [SharedTrendPoint<Double>]
    let xDomain: [String]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Breathing Rate")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
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
                .padding(.vertical, 24)
                
                Spacer()
            }
        }
    }
}

private struct SharedTrendPoint<Value>: Identifiable {
    let dayLabel: String
    let value: Value?

    var id: String { dayLabel }
}
