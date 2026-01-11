import Foundation
import SwiftUI

@MainActor
final class AppNavigation: ObservableObject {
    /// Matches `ContentView` tab indices.
    @Published var selectedTab: Int = 0
}
