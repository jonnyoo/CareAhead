import SwiftUI

struct CameraView: View {
    var body: some View {
        ZStack {
            // Main Background
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Gradient Background (30% of screen)
                GeometryReader { geometry in
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 403, height: 237)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.44, green: 0.86, blue: 0.7), location: 0.10),
                                    Gradient.Stop(color: Color(red: 0.7, green: 0.73, blue: 1).opacity(0.5), location: 0.47),
                                    Gradient.Stop(color: Color(red: 1, green: 0.74, blue: 0.29).opacity(0.15), location: 0.68),
                                    Gradient.Stop(color: Color(red: 1, green: 0.77, blue: 0.25).opacity(0), location: 0.84),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.63, y: 0.96)
                            )
                        )
                        .opacity(0.3)
                }
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Camera View
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                    
                    Text("Camera Preview")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(width: 368, height: 619)
                .cornerRadius(20)
                .shadow(color: .white.opacity(0.2), radius: 4.95, x: 0, y: 0)
                .shadow(color: .black.opacity(0.11), radius: 2, x: 0, y: -4)
            }
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    CameraView()
}
