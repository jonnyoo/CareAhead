import Foundation

struct GeminiSettings: Equatable {
    var apiKey: String

    var isValid: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // NOTE: Hardcoded key (per request). Consider using Keychain/xcconfig for production.
    static let `default` = GeminiSettings(apiKey: "AIzaSyDgG4MMPHNO7UKQeeHaErPbWwqD9QZuyZM")
}

    // MARK: - Persistence & Loading Logic
    
    private static let service = "CareAhead.Gemini"
    private enum Account {
        static let apiKey = "apiKey"
    }

    /// Loads the settings from Info.plist (secure) or Keychain (legacy)
    static func load() throws -> GeminiSettings {
        var apiKey = try KeychainStore.getString(service: service, account: Account.apiKey) ?? ""

        // Dev convenience: allow injecting the key via generated Info.plist from Secrets.xcconfig.
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let injected = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.apiKey) as? String,
           !injected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            apiKey = injected
            try? KeychainStore.setString(apiKey, service: service, account: Account.apiKey)
        }

        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            apiKey = GeminiSettings.default.apiKey
            try? KeychainStore.setString(apiKey, service: service, account: Account.apiKey)
        }

        return GeminiSettings(apiKey: apiKey)
    }

    static func save(_ settings: GeminiSettings) throws {
        try KeychainStore.setString(settings.apiKey, service: service, account: Account.apiKey)
    }

    static func clear() throws {
        try KeychainStore.delete(service: service, account: Account.apiKey)
    }
}
