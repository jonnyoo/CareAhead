//
//  CareAheadApp.swift
//  CareAhead
//
//  Created by Jonathan Zhou on 2026-01-10.
//

import SwiftUI
import SwiftData

@main
struct CareAheadApp: App {
    @StateObject private var nav = AppNavigation()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VitalSign.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(nav)
        }
        .modelContainer(sharedModelContainer)
    }
}
