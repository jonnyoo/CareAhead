import SwiftUI

struct GeminiInsightScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.44, green: 0.86, blue: 0.7).opacity(0.22), location: 0.0),
                    .init(color: Color(red: 0.70, green: 0.73, blue: 1.0).opacity(0.20), location: 0.45),
                    .init(color: Color("backgroundColor"), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                        .padding(.top, 18)

                        GeminiInsightView(autoGenerateOnAppear: true, isFullScreen: true)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 44)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Insight")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 0.36, green: 0.78, blue: 0.7))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.75))
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    GeminiInsightScreen()
}
