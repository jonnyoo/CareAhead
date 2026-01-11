import SwiftUI
import SwiftData
import Combine

@MainActor
final class GeminiInsightViewModel: ObservableObject {
    @Published var insightText: String = ""
    @Published var errorText: String = ""
    @Published var isBusy: Bool = false

    @Published var settings: GeminiSettings = .default
    @Published var isShowingSettings: Bool = false

    func loadSettings() {
        do {
            settings = try GeminiSettingsStore.load()
        } catch {
            settings = .default
        }
    }

    func saveSettings() {
        do {
            try GeminiSettingsStore.save(settings)
        } catch {
            errorText = error.localizedDescription
        }
    }

    func generate(today: VitalSign, history: [VitalSign]) {
        Task {
            await self.runBusy {
                let input = GeminiInsightInput(today: today, history: history)
                let prompt = GeminiInsightPromptBuilder.build(input: input)
                let client = GeminiClient(settings: self.settings)
                let text = try await client.generateText(prompt: prompt)
                self.insightText = text
                self.errorText = ""
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

struct GeminiInsightView: View {
    @Environment(\.modelContext) private var modelContext

    // Get enough data for comparisons
    @Query(sort: \VitalSign.timestamp, order: .reverse) private var vitalSigns: [VitalSign]

    @StateObject private var model = GeminiInsightViewModel()

    var autoGenerateOnAppear: Bool = false

    @State private var didAutoGenerate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today’s Insight")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.17, green: 0.18, blue: 0.35))

                Spacer()

                Button("Settings") {
                    model.isShowingSettings = true
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.75))
            }

            let todayVital = latestTodayVitalSign
            if todayVital == nil {
                Text("Run today’s video test to get an insight.")
                    .foregroundStyle(.secondary)
            } else {
                Button(model.isBusy ? "Generating…" : "Generate Insight") {
                    guard let todayVital else { return }
                    model.generate(today: todayVital, history: historyForComparison)
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.isBusy)
            }

            if !model.errorText.isEmpty {
                Text(model.errorText)
                    .foregroundStyle(.red)
                    .font(.system(size: 14))
            }

            if !model.insightText.isEmpty {
                Text(model.insightText)
                    .font(.system(.body, design: .default))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)
        .onAppear {
            self.model.loadSettings()

            if self.autoGenerateOnAppear,
               !self.didAutoGenerate,
               self.model.settings.isValid,
               let todayVital = latestTodayVitalSign {
                self.didAutoGenerate = true
                self.model.generate(today: todayVital, history: self.historyForComparison)
            }
        }
        .sheet(isPresented: $model.isShowingSettings) {
            GeminiSettingsSheet(settings: $model.settings, onSave: {
                self.model.saveSettings()
            })
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
}

private struct GeminiSettingsSheet: View {
    @Environment(\.dismiss) var dismiss

    @Binding var settings: GeminiSettings
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gemini API")) {
                    SecureField("API Key", text: $settings.apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Model", text: $settings.model)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("Use a key from Google AI Studio. This key is stored in Keychain on-device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Insight Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GeminiInsightView()
}
