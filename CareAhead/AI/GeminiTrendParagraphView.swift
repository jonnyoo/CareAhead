import SwiftUI
import Combine

@MainActor
final class GeminiTrendParagraphViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isBusy: Bool = false
    @Published var errorText: String = ""

    private var didStart: Bool = false

    func generateIfNeeded(prompt: String) {
        guard !didStart else { return }
        didStart = true
        
        Task {
            await runBusy {
                self.text = ""
                self.errorText = ""
                

                guard let settings = try? GeminiSettings.load() else {
                    self.errorText = "Could not load API Key from Secrets."
                    return
                }
                
                let client = GeminiClient(settings: settings)
                // --- UPDATED SECTION END ---
                
                let response = try await client.generateText(prompt: prompt)
                
                self.text = response.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }

    private func runBusy(_ work: @escaping () async throws -> Void) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        do {
            try await work()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

struct GeminiTrendParagraphView: View {
    let prompt: String
    let fallbackText: String

    @StateObject private var model = GeminiTrendParagraphViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.text.isEmpty ? fallbackText : model.text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))
                .lineSpacing(4)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: model.text)

            if model.isBusy && model.text.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                    Text("Refining with AI…")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                }
            }

            if !model.errorText.isEmpty {
                Text("Showing baseline summary (AI unavailable).")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.55))
            }
        }
        .onAppear {
            model.generateIfNeeded(prompt: prompt)
        }
    }
}
