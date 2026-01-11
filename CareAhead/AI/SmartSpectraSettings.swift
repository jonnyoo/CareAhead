import Foundation

struct SmartSpectraSettings: Equatable {
    var apiKey: String

    var isValid: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static let `default` = SmartSpectraSettings(apiKey: "")
}

enum SmartSpectraSettingsStore {
    private static let service = "CareAhead.SmartSpectra"

    private enum InfoPlistKey {
        static let apiKey = "SmartSpectraApiKey"
    }

    private enum Account {
        static let apiKey = "apiKey"
    }

    static func load() throws -> SmartSpectraSettings {
        var apiKey = try KeychainStore.getString(service: service, account: Account.apiKey) ?? ""

        // Dev convenience: allow injecting the key via generated Info.plist from Secrets.xcconfig.
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let injected = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.apiKey) as? String,
           !injected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            apiKey = injected
            try? KeychainStore.setString(apiKey, service: service, account: Account.apiKey)
        }

        return SmartSpectraSettings(apiKey: apiKey)
    }

    static func save(_ settings: SmartSpectraSettings) throws {
        try KeychainStore.setString(settings.apiKey, service: service, account: Account.apiKey)
    }

    static func clear() throws {
        try KeychainStore.delete(service: service, account: Account.apiKey)
    }
}
