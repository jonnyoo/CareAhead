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

                let client = GeminiClient(settings: GeminiSettings.default)
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

    @StateObject private var model = GeminiTrendParagraphViewModel()

    var body: some View {
        Group {
            if model.isBusy && model.text.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(Color(red: 0.45, green: 0.48, blue: 0.75))
                    Text("Generating…")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.75))
                }
                .padding(.top, 4)
            } else if !model.errorText.isEmpty {
                Text(model.errorText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
            } else if !model.text.isEmpty {
                Text(model.text)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))
                    .lineSpacing(4)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: model.text)
            }
        }
        .onAppear {
            model.generateIfNeeded(prompt: prompt)
        }
    }
}
