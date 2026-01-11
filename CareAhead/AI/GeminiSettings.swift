import Foundation

struct GeminiSettings: Equatable {
    var apiKey: String
    var model: String

    var isValid: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static let `default` = GeminiSettings(apiKey: "", model: "gemini-1.5-flash")
}

enum GeminiSettingsStore {
    private static let service = "CareAhead.Gemini"

    private enum Account {
        static let apiKey = "apiKey"
        static let model = "model"
    }

    static func load() throws -> GeminiSettings {
        let apiKey = try KeychainStore.getString(service: service, account: Account.apiKey) ?? ""
        let model = try KeychainStore.getString(service: service, account: Account.model) ?? GeminiSettings.default.model
        return GeminiSettings(apiKey: apiKey, model: model)
    }

    static func save(_ settings: GeminiSettings) throws {
        try KeychainStore.setString(settings.apiKey, service: service, account: Account.apiKey)
        try KeychainStore.setString(settings.model, service: service, account: Account.model)
    }

    static func clear() throws {
        try KeychainStore.delete(service: service, account: Account.apiKey)
        try KeychainStore.delete(service: service, account: Account.model)
    }
}
