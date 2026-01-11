import SwiftUI
import SwiftData
import Charts

@MainActor
final class GeminiInsightViewModel: ObservableObject {
    @Published var sections: GeminiInsightSections? = nil
    @Published var errorText: String = ""
    @Published var isBusy: Bool = false
    @Published var showText: Bool = false

    let settings: GeminiSettings = .default

    func generate(today: VitalSign, history: [VitalSign]) {
        Task {
            await self.runBusy {
                self.sections = nil
                self.errorText = ""
                self.showText = false

                let input = GeminiInsightInput(today: today, history: history)
                let prompt = GeminiInsightPromptBuilder.build(input: input)
                let client = GeminiClient(settings: self.settings)

                let text = try await client.generateText(prompt: prompt)

                let parsed = GeminiInsightSections.parse(from: text)
                self.sections = parsed ?? GeminiInsightSections(
                    introduction: [text.trimmingCharacters(in: .whitespacesAndNewlines)],
                    heartRateDiscussion: [],
                    breathingRateDiscussion: [],
                    finalThoughts: [],
                    disclaimer: "Not medical advice."
                )

                withAnimation(.easeInOut(duration: 0.35)) {
                    self.showText = true
                }
            }
        }
    }

    private func runBusy(_ work: @escaping () async throws -> Void) async {
        guard !self.isBusy else { return }
        self.isBusy = true
        defer { self.isBusy = false }

        do {
            try await work()
        } catch {
            self.errorText = error.localizedDescription
        }
    }
}

struct GeminiInsightSections: Decodable {
    let introduction: [String]
    let heartRateDiscussion: [String]
    let breathingRateDiscussion: [String]
    let finalThoughts: [String]
    let disclaimer: String?

    static func parse(from raw: String) -> GeminiInsightSections? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let start = trimmed.firstIndex(of: "{"),
              let end = trimmed.lastIndex(of: "}"),
              start < end
        else {
            return nil
        }

        let json = String(trimmed[start...end])
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(GeminiInsightSections.self, from: data)
    }
}

struct GeminiInsightView: View {
    // Get enough data for comparisons
    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    @StateObject private var model = GeminiInsightViewModel()

    let heartRateSeries: [LiveMetricPoint]
    let breathingRateSeries: [LiveMetricPoint]

    var autoGenerateOnAppear: Bool = false
    var isFullScreen: Bool = false

    @State private var didAutoGenerate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let todayVital = latestTodayVitalSign
            if todayVital == nil {
                insightCard {
                    Text("Run today’s video test to get an insight.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
            } else if let todayVital {
                vitalsRow(todayVital)
                    .padding(.top, 2)

                if !model.errorText.isEmpty {
                    insightCard {
                        Text(model.errorText)
                            .foregroundStyle(.red)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                }

                if model.isBusy && model.sections == nil {
                    insightCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Generating insight…")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.85))
                            ProgressView()
                                .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                        }
                        .padding(.vertical, 6)
                    }
                }

                if let sections = model.sections {
                    sectionCard(title: "Introduction", paragraphs: sections.introduction)
                        .opacity(model.showText ? 1 : 0)
                        .animation(.easeInOut(duration: 0.35), value: model.showText)

                    heartRateChartCard

                    sectionCard(title: "Heart Rate", paragraphs: sections.heartRateDiscussion)
                        .opacity(model.showText ? 1 : 0)
                        .animation(.easeInOut(duration: 0.35), value: model.showText)

                    breathingRateChartCard

                    sectionCard(title: "Breathing Rate", paragraphs: sections.breathingRateDiscussion)
                        .opacity(model.showText ? 1 : 0)
                        .animation(.easeInOut(duration: 0.35), value: model.showText)

                    sectionCard(
                        title: "Final Thoughts",
                        paragraphs: sections.finalThoughts + [sections.disclaimer].compactMap { $0 }
                    )
                    .opacity(model.showText ? 1 : 0)
                    .animation(.easeInOut(duration: 0.35), value: model.showText)
                }

                if !autoGenerateOnAppear && model.sections == nil {
                    Button(model.isBusy ? "Generating…" : "Generate Insight") {
                        model.generate(today: todayVital, history: historyForComparison)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                    .disabled(model.isBusy)
                }
            }
        }
        .padding(isFullScreen ? 0 : 16)
        .background(
            Group {
                if isFullScreen {
                    Color.clear
                } else {
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 0.98, green: 0.98, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: isFullScreen ? 0 : 20))
        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(isFullScreen ? 0 : 0.45), radius: 8, x: 0, y: 2)
        .onAppear {
            if self.autoGenerateOnAppear,
               !self.didAutoGenerate,
               let todayVital = latestTodayVitalSign {
                self.didAutoGenerate = true
                self.model.generate(today: todayVital, history: self.historyForComparison)
            }
        }
    }

    private func insightCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)

            content()
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionCard(title: String, paragraphs: [String]) -> some View {
        guard !paragraphs.isEmpty else {
            return AnyView(EmptyView())
        }

        return AnyView(
            insightCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))

                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.9))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        )
    }

    private var heartRateChartCard: some View {
        chartCard(
            title: "Heart Rate",
            unit: "bpm",
            tint: Color(red: 0.36, green: 0.78, blue: 0.7),
            series: heartRateSeries,
            yDomain: 40...140
        )
    }

    private var breathingRateChartCard: some View {
        chartCard(
            title: "Breathing Rate",
            unit: "rpm",
            tint: Color(red: 0.7, green: 0.73, blue: 1),
            series: breathingRateSeries,
            yDomain: 8...30
        )
    }

    private func chartCard(
        title: String,
        unit: String,
        tint: Color,
        series: [LiveMetricPoint],
        yDomain: ClosedRange<Double>
    ) -> some View {
        insightCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))

                    Spacer()

                    if let last = series.last {
                        Text("\(Int(last.value.rounded())) \(unit)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.75))
                    }
                }

                if series.isEmpty {
                    Text("No live trace recorded.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.65))
                        .padding(.vertical, 6)
                } else {
                    Chart {
                        ForEach(series) { point in
                            LineMark(
                                x: .value("t", point.t),
                                y: .value("value", point.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            .foregroundStyle(tint)

                            AreaMark(
                                x: .value("t", point.t),
                                y: .value("value", point.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [tint.opacity(0.28), tint.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 140)
                    .chartYScale(domain: yDomain)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                            AxisValueLabel()
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.12))
                            AxisValueLabel()
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.62))
                        }
                    }
                }
            }
        }
    }

    private var latestTodayVitalSign: VitalSign? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return vitalSigns.first(where: { calendar.isDate($0.timestamp, inSameDayAs: start) })
    }

    private var historyForComparison: [VitalSign] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // up to 30 previous days, excluding today
        return vitalSigns
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: today) }
            .prefix(60) // keep a bit extra; prompt builder will trim
            .map { $0 }
    }

    private func vitalsRow(_ vital: VitalSign) -> some View {
        HStack(spacing: 10) {
            chip(title: "HR", value: "\(vital.heartRate)", unit: "bpm")
            chip(title: "BR", value: "\(vital.breathingRate)", unit: "rpm")

            if let sleep = vital.sleepHours {
                chip(title: "Sleep", value: String(format: "%.1f", sleep), unit: "h")
            }

            Spacer()
        }
    }

    private func chip(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.65))
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))
                Text(unit)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.55))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.45, green: 0.48, blue: 0.75).opacity(0.18), lineWidth: 1)
        )
    }
}

#Preview {
    GeminiInsightView(heartRateSeries: [], breathingRateSeries: [])
}
