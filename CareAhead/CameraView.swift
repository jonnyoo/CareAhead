import SwiftUI

struct CameraView: View {
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.75, green: 0.92, blue: 0.90),
                    Color(red: 0.85, green: 0.88, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Camera View")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
            }
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    CameraView()
}
