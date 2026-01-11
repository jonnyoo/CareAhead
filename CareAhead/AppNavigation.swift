import Foundation
import SwiftUI
import Combine

final class AppNavigation: ObservableObject {
    /// Matches `ContentView` tab indices.
    @Published var selectedTab: Int = 0
}
