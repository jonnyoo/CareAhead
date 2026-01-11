import Foundation

struct GeminiClient {
    enum GeminiError: Error, LocalizedError {
        case missingApiKey
        case invalidURL
        case httpError(statusCode: Int, body: String)
        case emptyResponse

        var errorDescription: String? {
            switch self {
            case .missingApiKey:
                return "Missing Gemini API key. Add it in the Insight panel settings."
            case .invalidURL:
                return "Invalid Gemini URL"
            case .httpError(let statusCode, let body):
                return "Gemini HTTP \(statusCode): \(body)"
            case .emptyResponse:
                return "Gemini returned an empty response"
            }
        }
    }

    let settings: GeminiSettings
    let session: URLSession

    init(settings: GeminiSettings, session: URLSession = .shared) {
        self.settings = settings
        self.session = session
    }

    func generateText(prompt: String) async throws -> String {
        guard settings.isValid else { throw GeminiError.missingApiKey }

        // Google AI Studio / Generative Language API
        // https://ai.google.dev/api/generate-content
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(settings.model):generateContent?key=\(settings.apiKey)") else {
            throw GeminiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiGenerateContentRequest(
            contents: [
                GeminiContent(parts: [GeminiPart(text: prompt)])
            ],
            generationConfig: GeminiGenerationConfig(temperature: 0.4, maxOutputTokens: 512)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)
        request.httpBody = data

        let (responseData, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(http.statusCode) {
            let bodyString = String(data: responseData, encoding: .utf8) ?? ""
            throw GeminiError.httpError(statusCode: http.statusCode, body: bodyString)
        }

        let decoded = try JSONDecoder().decode(GeminiGenerateContentResponse.self, from: responseData)
        let text = decoded.candidates
            .first?.content.parts
            .compactMap { $0.text }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text, !text.isEmpty else {
            throw GeminiError.emptyResponse
        }

        return text
    }
}

// MARK: - API models

struct GeminiGenerateContentRequest: Encodable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
}

struct GeminiContent: Encodable, Decodable {
    let parts: [GeminiPart]
}

struct GeminiPart: Encodable, Decodable {
    let text: String?
}

struct GeminiGenerationConfig: Encodable {
    let temperature: Double?
    let maxOutputTokens: Int?
}

struct GeminiGenerateContentResponse: Decodable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Decodable {
    let content: GeminiContent
}
