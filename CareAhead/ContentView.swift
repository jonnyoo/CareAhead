import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            // Current Page View
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    MapView()
                case 2:
                    PresageView()
                case 3:
                    TrendsView()
                case 4:
                    SharedView()
                default:
                    HomeView()
                }
            }
            
            // Floating Tab Bar
            VStack {
                Spacer()
                TabBarView(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    ContentView()
}
