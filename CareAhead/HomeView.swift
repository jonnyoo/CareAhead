import SwiftUI

struct HomeView: View {
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
                        
                        // Heart Rate Card
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 0.88, green: 0.88, blue: 0.95).opacity(0.6))
                                .frame(height: 220)
                            
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Heart Rate")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.45))
                                    
                                    Text("Your heart rate\nover the past week\nhas been\nconsistent with\nprevious data.")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.5))
                                        .lineSpacing(2)
                                }
                                .padding(.leading, 28)
                                .padding(.bottom, 28)
                                
                                Spacer()
                                
                                // Bar Chart
                                HStack(alignment: .bottom, spacing: 12) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.4, green: 0.8, blue: 0.7))
                                        .frame(width: 36, height: 120)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.5, green: 0.85, blue: 0.75))
                                        .frame(width: 36, height: 90)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.5, green: 0.85, blue: 0.75))
                                        .frame(width: 36, height: 85)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.5, green: 0.85, blue: 0.75))
                                        .frame(width: 36, height: 100)
                                }
                                .padding(.trailing, 28)
                                .padding(.bottom, 28)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Current Suggestions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Suggestions")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                SuggestionCard(
                                    title: "Monitor blood sugar",
                                    description: "Your blood pressure has recently been up 10%.",
                                    icon: "drop.fill"
                                )
                                
                                SuggestionCard(
                                    title: "Hydration",
                                    description: "Drink at least 2L of water every day",
                                    icon: "drop.fill"
                                )
                            }
                            
                            SuggestionCard(
                                title: "Exercise",
                                description: "Go for a walk to maintain cardiovascular",
                                icon: "figure.walk",
                                isWide: true
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
}

struct SuggestionCard: View {
    let title: String
    let description: String
    let icon: String
    var isWide: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.9, green: 0.9, blue: 0.96).opacity(0.7))
                .frame(height: isWide ? 140 : 180)
            
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
        }
    }
}

#Preview {
    HomeView()
}
