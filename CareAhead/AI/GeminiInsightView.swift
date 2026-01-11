import SwiftUI
import SwiftData
import Combine

@MainActor
final class GeminiInsightViewModel: ObservableObject {
    @Published var insightText: String = ""
    @Published var errorText: String = ""
    @Published var isBusy: Bool = false
    @Published var isRevealing: Bool = false

    let settings: GeminiSettings = .default

    private var revealTask: Task<Void, Never>?

    func generate(today: VitalSign, history: [VitalSign]) {
        Task {
            await self.runBusy {
                self.revealTask?.cancel()
                self.isRevealing = false
                self.insightText = ""
                self.errorText = ""

                let input = GeminiInsightInput(today: today, history: history)
                let prompt = GeminiInsightPromptBuilder.build(input: input)
                let client = GeminiClient(settings: self.settings)

                let text = try await client.generateText(prompt: prompt)

                // Smooth reveal: simulate text fading/typing in.
                self.isRevealing = true
                self.revealTask = Task { [weak self] in
                    guard let self else { return }
                    await self.revealText(text)
                }
            }
        }
    }

    private func revealText(_ fullText: String) async {
        // Reveal in chunks so it feels smooth without being too slow.
        let scalars = Array(fullText.unicodeScalars)
        let total = scalars.count

        // Roughly finish in ~1.6s for typical responses.
        let targetSteps = 90
        let chunkSize = max(1, total / targetSteps)

        var index = 0
        while index < total {
            if Task.isCancelled { return }
            let next = min(total, index + chunkSize)
            let slice = String(String.UnicodeScalarView(scalars[0..<next]))
            self.insightText = slice
            index = next
            try? await Task.sleep(nanoseconds: 18_000_000) // ~18ms
        }

        self.insightText = fullText
        self.isRevealing = false
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

struct GeminiInsightView: View {
    // Get enough data for comparisons
    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    @StateObject private var model = GeminiInsightViewModel()

    var autoGenerateOnAppear: Bool = false
    var isFullScreen: Bool = false

    @State private var didAutoGenerate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.75))

                Text("Today’s Insight")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))

                Spacer()

                if model.isBusy {
                    ProgressView()
                        .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                }
            }

            let todayVital = latestTodayVitalSign
            if todayVital == nil {
                Text("Run today’s video test to get an insight.")
                    .foregroundStyle(.secondary)
            } else {
                if let todayVital {
                    vitalsRow(todayVital)
                        .padding(.top, 2)

                    // If not auto-generating (e.g., used as a card), allow a single manual generate.
                    if !autoGenerateOnAppear && model.insightText.isEmpty {
                        Button(model.isBusy ? "Generating…" : "Generate Insight") {
                            model.generate(today: todayVital, history: historyForComparison)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                        .disabled(model.isBusy)
                    }
                }
            }

            if !model.errorText.isEmpty {
                Text(model.errorText)
                    .foregroundStyle(.red)
                    .font(.system(size: 14))
            }

            if model.isBusy && model.insightText.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Generating insight…")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.8))
                    ProgressView()
                        .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            if !model.insightText.isEmpty {
                Group {
                    if let attributed = try? AttributedString(markdown: model.insightText) {
                        Text(attributed)
                    } else {
                        Text(model.insightText)
                    }
                }
                .textSelection(.enabled)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .opacity(model.isRevealing ? 0.92 : 1.0)
                .animation(.easeInOut(duration: 0.25), value: model.insightText)
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
    GeminiInsightView()
}
