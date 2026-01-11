import Foundation

struct GeminiSettings: Equatable {
    var apiKey: String

    var isValid: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static let `default` = GeminiSettings(apiKey: "")

    // MARK: - Persistence & Loading Logic
    
    private static let service = "CareAhead.Gemini"
    private enum Account {
        static let apiKey = "apiKey"
    }

    private enum InfoPlistKey {
        // This key is injected via Xcode build setting: INFOPLIST_KEY_GeminiApiKey
        static let apiKey = "GeminiApiKey"

        // Back-compat if the app was built with a different plist key.
        static let legacyApiKey = "GEMINI_API_KEY"
    }

    /// Loads the settings from Info.plist (Secrets.xcconfig -> build settings -> Info.plist) or Keychain.
    static func load() throws -> GeminiSettings {
        let keychainValue = (try KeychainStore.getString(service: service, account: Account.apiKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let injectedValue = (
            (Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.apiKey) as? String)
                ?? (Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.legacyApiKey) as? String)
                ?? ""
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)

        // Prefer the build-injected key so changing Secrets.xcconfig fixes the app even
        // if an older (expired) key was previously cached in Keychain.
        if !injectedValue.isEmpty {
            if injectedValue != keychainValue {
                try? KeychainStore.setString(injectedValue, service: service, account: Account.apiKey)
            }
            return GeminiSettings(apiKey: injectedValue)
        }

        // Fall back to Keychain (e.g., if you add an in-app settings screen later).
        return GeminiSettings(apiKey: keychainValue)
    }

    static func save(_ settings: GeminiSettings) throws {
        try KeychainStore.setString(settings.apiKey, service: service, account: Account.apiKey)
    }

    static func clear() throws {
        try KeychainStore.delete(service: service, account: Account.apiKey)
    }
}

