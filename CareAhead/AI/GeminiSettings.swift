import Foundation

struct GeminiSettings: Equatable {
    var apiKey: String

    var isValid: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

enum GeminiSettingsStore {
    private static let service = "CareAhead.Gemini"

    private enum InfoPlistKey {
        static let apiKey = "GeminiApiKey"
    }

    private enum Account {
        static let apiKey = "apiKey"
    }

    static func load() throws -> GeminiSettings {
        // 1. Read from the secure Info.plist entry
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GeminiApiKey") as? String, !plistKey.isEmpty {
            if plistKey.contains("GEMINI_API_KEY") {
                print("⚠️ Warning: Config file not linked. Seeing variable name instead of value.")
            }
            return GeminiSettings(apiKey: plistKey)
        }

        // 2. Fallback to Keychain (if you still want to support it)
        if let key = try? KeychainStore.getString(service: service, account: Account.apiKey) {
            return GeminiSettings(apiKey: key)
        }
        
        // 3. Last resort / Error
        print("❌ Error: API Key not found in Info.plist or Keychain")
        return GeminiSettings(apiKey: "")
    }

    static func save(_ settings: GeminiSettings) throws {
        try KeychainStore.setString(settings.apiKey, service: service, account: Account.apiKey)
    }

    static func clear() throws {
        try KeychainStore.delete(service: service, account: Account.apiKey)
    }
}
