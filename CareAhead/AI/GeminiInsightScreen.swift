import SwiftUI

struct GeminiInsightScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()

                ScrollView {
                    GeminiInsightView(autoGenerateOnAppear: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Insight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    GeminiInsightScreen()
}
