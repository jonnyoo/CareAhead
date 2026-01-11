import SwiftUI
import Charts

struct GeminiInsightScreen: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var nav: AppNavigation

    let heartRateSeries: [LiveMetricPoint]
    let breathingRateSeries: [LiveMetricPoint]

    var body: some View {
        ZStack {
            Color("backgroundColor")
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

                    liveScanCharts

                    insightCard {
                        GeminiInsightView(autoGenerateOnAppear: true, isFullScreen: true)
                    }

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

    private var liveScanCharts: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Live scan")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))

            if heartRateSeries.isEmpty && breathingRateSeries.isEmpty {
                insightCard {
                    Text("No live trace recorded. Run the video test to capture the live chart.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
            } else {
                insightCard {
                    VStack(alignment: .leading, spacing: 14) {
                        liveLineChart(
                            title: "Heart Rate",
                            unit: "bpm",
                            tint: Color(red: 0.36, green: 0.78, blue: 0.7),
                            series: heartRateSeries,
                            yDomain: 40...140
                        )

                        Divider().opacity(0.2)

                        liveLineChart(
                            title: "Breathing Rate",
                            unit: "rpm",
                            tint: Color(red: 0.7, green: 0.73, blue: 1),
                            series: breathingRateSeries,
                            yDomain: 8...30
                        )
                    }
                }
            }
        }
    }

    private func insightCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color(red: 0.88, green: 0.89, blue: 1).opacity(0.45), radius: 8, x: 0, y: 2)

            content()
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func liveLineChart(
        title: String,
        unit: String,
        tint: Color,
        series: [LiveMetricPoint],
        yDomain: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35))

                Spacer()

                if let last = series.last {
                    Text("\(Int(last.value.rounded())) \(unit)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.75))
                }
            }

            Chart {
                ForEach(series) { point in
                    LineMark(
                        x: .value("t", point.t),
                        y: .value("value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(tint)

                    AreaMark(
                        x: .value("t", point.t),
                        y: .value("value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint.opacity(0.28), tint.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 140)
            .chartYScale(domain: yDomain)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.6))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.12))
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.35).opacity(0.62))
                }
            }
        }
    }
}

#Preview {
    GeminiInsightScreen(heartRateSeries: [], breathingRateSeries: [])
        .environmentObject(AppNavigation())
}
