import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            // Current Page View
            Group {
                switch selectedTab {
                case 0:
                    HomeView(selectedTab: $selectedTab)
                case 1:
                    MapView()
                case 2:
                    PresageView()
                case 3:
                    TrendsView()
                case 4:
                    SharedView()
                default:
                    HomeView(selectedTab: $selectedTab)
                }
            }
            
            // Floating Tab Bar
            VStack {
                Spacer()
                TabBarView(selectedTab: $selectedTab)
            }
        }
        .task {
            try? VitalSignSeeder.seedIfNeeded(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
