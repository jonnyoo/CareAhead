import SwiftUI
import SwiftData
import Charts
import Combine

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
                if let parsed {
                    self.sections = parsed.normalized()
                } else {
                    self.sections = GeminiInsightSections.fallback(from: text).normalized()
                }

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
    let introduction: String
    let heartRateDiscussion: String
    let breathingRateDiscussion: String
    let finalThoughts: String
    let disclaimer: String?

    init(
        introduction: String,
        heartRateDiscussion: String,
        breathingRateDiscussion: String,
        finalThoughts: String,
        disclaimer: String?
    ) {
        self.introduction = introduction
        self.heartRateDiscussion = heartRateDiscussion
        self.breathingRateDiscussion = breathingRateDiscussion
        self.finalThoughts = finalThoughts
        self.disclaimer = disclaimer
    }

    enum CodingKeys: String, CodingKey {
        case introduction
        case heartRateDiscussion
        case breathingRateDiscussion
        case finalThoughts
        case disclaimer
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.introduction = (try? Self.decodeStringOrStringArray(c, forKey: .introduction)) ?? ""
        self.heartRateDiscussion = (try? Self.decodeStringOrStringArray(c, forKey: .heartRateDiscussion)) ?? ""
        self.breathingRateDiscussion = (try? Self.decodeStringOrStringArray(c, forKey: .breathingRateDiscussion)) ?? ""
        self.finalThoughts = (try? Self.decodeStringOrStringArray(c, forKey: .finalThoughts)) ?? ""
        self.disclaimer = try? c.decode(String.self, forKey: .disclaimer)
    }

    private static func decodeStringOrStringArray(
        _ c: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> String {
        if let string = try? c.decode(String.self, forKey: key) {
            return string
        }
        if let array = try? c.decode([String].self, forKey: key) {
            return array.joined(separator: "\n\n")
        }
        return ""
    }

    static func parse(from raw: String) -> GeminiInsightSections? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let start = trimmed.firstIndex(of: "{"),
              let end = trimmed.lastIndex(of: "}"),
              start < end
        else {
            return nil
        }

        var json = String(trimmed[start...end])

        // Common model quirks: smart quotes, stray code fences, trailing commas.
        json = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "\u{201C}", with: "\"")
            .replacingOccurrences(of: "\u{201D}", with: "\"")
            .replacingOccurrences(of: "\u{2018}", with: "'")
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove trailing commas before } or ]
        json = json.replacingOccurrences(
            of: ",\\s*([}\\]])",
            with: "$1",
            options: [.regularExpression]
        )

        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(GeminiInsightSections.self, from: data)
    }

    func normalized() -> GeminiInsightSections {
        func clean(_ s: String) -> String {
            s.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let intro = clean(introduction)
        let hr = clean(heartRateDiscussion)
        let br = clean(breathingRateDiscussion)
        let final = clean(finalThoughts)

        return GeminiInsightSections(
            introduction: intro.isEmpty ? "Here’s a quick, baseline-aware read of today’s scan." : intro,
            heartRateDiscussion: hr.isEmpty ? "Your heart rate trace looks fairly steady overall. Small rises and dips are common during a camera scan (posture, breathing, tiny movements, lighting)." : hr,
            breathingRateDiscussion: br.isEmpty ? "Breathing rate estimates can vary more than heart rate in short clips. What matters most is the overall level and whether the trace stabilizes." : br,
            finalThoughts: final.isEmpty ? "For the cleanest comparison, run tomorrow’s test at a similar time, sitting still, with consistent lighting." : final,
            disclaimer: (disclaimer?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? disclaimer : "Not medical advice."
        )
    }

    static func fallback(from raw: String) -> GeminiInsightSections {
        // Last-resort: try to pull fields out even if JSON isn't fully valid.
        func extract(_ key: String) -> String? {
            // "key": "..."
            let pattern = "\\\"\\(key)\\\"\\s*:\\s*\\\"((?:\\\\.|[^\\\"])*)\\\""
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
            let range = NSRange(raw.startIndex..<raw.endIndex, in: raw)
            guard let match = regex.firstMatch(in: raw, range: range), match.numberOfRanges >= 2,
                  let r = Range(match.range(at: 1), in: raw)
            else { return nil }
            let captured = String(raw[r])
                .replacingOccurrences(of: "\\n", with: "\n")
                .replacingOccurrences(of: "\\\"", with: "\"")
            return captured
        }

        let intro = extract("introduction") ?? raw
        let hr = extract("heartRateDiscussion") ?? ""
        let br = extract("breathingRateDiscussion") ?? ""
        let final = extract("finalThoughts") ?? ""
        let disc = extract("disclaimer")

        return GeminiInsightSections(
            introduction: intro,
            heartRateDiscussion: hr,
            breathingRateDiscussion: br,
            finalThoughts: final,
            disclaimer: disc
        )
    }

    static func splitParagraphs(_ text: String) -> [String] {
        text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .split(whereSeparator: { $0.isEmpty })
            .map { $0.joined(separator: "\n") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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
                    sectionCard(title: "Introduction", paragraphs: GeminiInsightSections.splitParagraphs(sections.introduction))
                        .opacity(model.showText ? 1 : 0)
                        .animation(.easeInOut(duration: 0.35), value: model.showText)

                    heartRateChartCard

                    sectionCard(title: "Heart Rate", paragraphs: GeminiInsightSections.splitParagraphs(sections.heartRateDiscussion))
                        .opacity(model.showText ? 1 : 0)
                        .animation(.easeInOut(duration: 0.35), value: model.showText)

                    breathingRateChartCard

                    sectionCard(title: "Breathing Rate", paragraphs: GeminiInsightSections.splitParagraphs(sections.breathingRateDiscussion))
                        .opacity(model.showText ? 1 : 0)
                        .animation(.easeInOut(duration: 0.35), value: model.showText)

                    sectionCard(
                        title: "Final Thoughts",
                        paragraphs: GeminiInsightSections.splitParagraphs(sections.finalThoughts) + [sections.disclaimer].compactMap { $0 }
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
