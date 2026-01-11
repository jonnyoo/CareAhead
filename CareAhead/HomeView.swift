import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.965, green: 0.965, blue: 0.98)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 403, height: 237)
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
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning,")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.65))
                            Text("Bobber")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                        }
                        
                        Spacer()
                        
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.5, green: 0.65, blue: 0.95))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.6))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Looking Good Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.45, green: 0.48, blue: 0.75))
                            .frame(height: 200)
                        
                        HStack(alignment: .bottom, spacing: 0) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Looking Good!")
                                    .font(.system(size: 35, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Your health trends align\nwith the past few\nweeks.")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundColor(.white.opacity(0.95))
                                    .lineSpacing(4)
                            }
                            .padding(.leading, 28)
                            .padding(.bottom, 28)
                            
                            Spacer(minLength: 0)
                        }
                        
                        // Happy Face positioned absolutely in bottom-right corner
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image("happy")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 125, height: 125)
                            }
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal)
// ← ONLY change

                    
                    // Your Trends Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Your Trends")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                            
                            Spacer()
                            
                            Text("See all")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                        }
                        .padding(.horizontal)
                        
                        // Health Metrics Scroll View
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Heart Rate Card
                                HealthMetricCard(
                                    title: "Heart Rate",
                                    description: "Your heart rate\nover the past week\nhas been\nconsistent with\nprevious data.",
                                    barColors: [
                                        Color(red: 0.4, green: 0.8, blue: 0.7),
                                        Color(red: 0.5, green: 0.85, blue: 0.75),
                                        Color(red: 0.5, green: 0.85, blue: 0.75),
                                        Color(red: 0.5, green: 0.85, blue: 0.75)
                                    ],
                                    barHeights: [120, 90, 85, 100]
                                )
                                
                                // Breathing Card
                                HealthMetricCard(
                                    title: "Breathing",
                                    description: "Your breathing rate\nhas been stable and\nwithin normal range\nfor the past week.",
                                    barColors: [
                                        Color(red: 0.6, green: 0.75, blue: 0.95),
                                        Color(red: 0.65, green: 0.78, blue: 0.98),
                                        Color(red: 0.65, green: 0.78, blue: 0.98),
                                        Color(red: 0.6, green: 0.75, blue: 0.95)
                                    ],
                                    barHeights: [95, 110, 100, 105]
                                )
                                
                                // Stress Card
                                HealthMetricCard(
                                    title: "Stress",
                                    description: "Your stress levels\nhave decreased by 15%\ncompared to last week.",
                                    barColors: [
                                        Color(red: 0.95, green: 0.7, blue: 0.6),
                                        Color(red: 0.92, green: 0.65, blue: 0.55),
                                        Color(red: 0.92, green: 0.65, blue: 0.55),
                                        Color(red: 0.95, green: 0.7, blue: 0.6)
                                    ],
                                    barHeights: [70, 85, 60, 75]
                                )
                            }
                            .padding(.horizontal)
                        }
                }
                    // Current Suggestions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Suggestions")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            SuggestionCard(
                                title: "Monitor blood sugar",
                                description: "Your blood pressure has recently been up 10%.",
                                icon: "drop.fill",
                                cardNumber: 1,
                                isLarge: true
                            )
                            
                            VStack(spacing: 12) {
                                SuggestionCard(
                                    title: "Hydration",
                                    description: "Drink at least 2L of water every day",
                                    icon: "drop.fill",
                                    cardNumber: 2
                                )
                            
                                SuggestionCard(
                                    title: "Exercise",
                                    description: "Go for a walk to maintain cardiovascular",
                                    icon: "figure.walk",
                                    cardNumber: 3,
                                    isWide: true
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
}

struct HealthMetricCard: View {
    let title: String
    let description: String
    let barColors: [Color]
    let barHeights: [Double]
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.88, green: 0.88, blue: 0.95).opacity(0.6))
                .frame(height: 220)
                .frame(minWidth: 280)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .padding(.top, 20)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.45))
                    
                    Text(description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.5))
                        .lineSpacing(2)
                }
                .padding(.leading, 28)
                .padding(.bottom, 28)
                
                Spacer()
                
                // Bar Chart
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<barHeights.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(barColors[index])
                            .frame(width: 36, height: barHeights[index])
                    }
                }
                .padding(.trailing, 28)
                .padding(.bottom, 28)
            }
        }
    }
}

struct SuggestionCard: View {
    let title: String
    let description: String
    let icon: String
    let cardNumber: Int
    var isWide: Bool = false
    var isLarge: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient/Color background
            if isLarge {
                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: Color(red: 0.85, green: 0.87, blue: 0.97), location: 0),
                        Gradient.Stop(color: Color.white, location: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.9, blue: 0.96).opacity(0.8),
                        Color(red: 0.85, green: 0.88, blue: 0.98).opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            if !isLarge {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: isWide ? 140 : 180)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: isWide ? 24 : 22, weight: .bold))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75).opacity(0.8))
                    .lineSpacing(2)
            }
            .padding(20)
            
            // Card number at bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("\(cardNumber)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.75).opacity(0.15))
                        .padding(.trailing, 5)
                        .padding(.bottom, 0)
                }
            }
        }
        .frame(height: isLarge ? 333 : (isWide ? 140 : 180))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HomeView()
}
