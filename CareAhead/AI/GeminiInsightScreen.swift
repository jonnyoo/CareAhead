import SwiftUI

struct GeminiInsightScreen: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var nav: AppNavigation

    let heartRateSeries: [LiveMetricPoint]
    let breathingRateSeries: [LiveMetricPoint]

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.98, green: 0.985, blue: 1.0)
                .ignoresSafeArea()

            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 237)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.44, green: 0.86, blue: 0.7), location: 0.10),
                            Gradient.Stop(color: Color(red: 0.7, green: 0.73, blue: 1).opacity(0.9), location: 0.47),
                            Gradient.Stop(color: Color(red: 1, green: 0.74, blue: 0.29).opacity(0.55), location: 0.68),
                            Gradient.Stop(color: Color(red: 1, green: 0.77, blue: 0.25).opacity(0), location: 0.84),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.63, y: 0.96)
                    )
                    .opacity(0.3)
                )
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                        .padding(.top, 20)

                    GeminiInsightView(
                        heartRateSeries: heartRateSeries,
                        breathingRateSeries: breathingRateSeries,
                        autoGenerateOnAppear: true,
                        isFullScreen: true
                    )

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Insights")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.35))
            }

            Spacer()

            Button {
                nav.selectedTab = 3
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
    GeminiInsightScreen(heartRateSeries: [], breathingRateSeries: [])
        .environmentObject(AppNavigation())
}
