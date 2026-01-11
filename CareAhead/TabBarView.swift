import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItemView(icon: "house.fill", isSelected: selectedTab == 0)
                .onTapGesture { selectedTab = 0 }
            
            TabBarItemView(icon: "map.fill", isSelected: selectedTab == 1)
                .onTapGesture { selectedTab = 1 }
            
            TabBarItemView(icon: "cross.fill", isSelected: selectedTab == 2)
                .onTapGesture { selectedTab = 2 }
            
            TabBarItemView(icon: "waveform.path.ecg", isSelected: selectedTab == 3)
                .onTapGesture { selectedTab = 3 }
            
            TabBarItemView(icon: "person.2.fill", isSelected: selectedTab == 4)
                .onTapGesture { selectedTab = 4 }
        }
        .frame(height: 60)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal, 40)
        .padding(.bottom, -5)
    }
}

struct TabBarItemView: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color(red: 0.45, green: 0.48, blue: 0.75) : Color.gray.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            TabBarView(selectedTab: .constant(0))
        }
    }
}
