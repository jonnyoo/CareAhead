import SwiftUI

struct SharedView: View {
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
                Text("Shared View")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
            }
            .padding(.bottom, 100)
        }
    }
}



// MARK: - Screen

struct SharingView: View {

    // Mock data using asset names
    private let updates: [UpdateCard] = [
        .init(avatarAsset: "smallAmy", name: "Amy Z.", time: "yesterday",
              message: "Heart rate has been\nhigher than usual for\nthe past week"),
        .init(avatarAsset: "smallTom", name: "Tom Z.", time: "yesterday",
              message: "Heart rate has been\nhigher than usual for\nthe past week")
    ]

    private let contacts: [ShareContact] = [
        .init(avatarAsset: "Amy", name: "Amy Z.", relation: "Mother", moodAsset: "greenHappy"),
        .init(avatarAsset: "bigTom", name: "Tom Z.", relation: "Father", moodAsset: "sadface"),
        .init(avatarAsset: "raymond", name: "Raymond Z.", relation: "Brother", moodAsset: "neutralFace")
    ]

    @State private var selectedTab: Tab = .sharing

    enum Tab: CaseIterable {
        case home, sharing, vitals, explore

        var sf: String {
            switch self {
            case .home: return "house"
            case .sharing: return "person.2"
            case .vitals: return "waveform.path.ecg"
            case .explore: return "map"
            }
        }
    }

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Sharing")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color(hex: 0x1E2447))
                    .padding(.top, 10)

                // Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(updates) { item in
                            UpdateCardView(item: item)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(height: 170)
                .padding(.horizontal, -22)

                // Contacts
                VStack(spacing: 14) {
                    ForEach(contacts) { contact in
                        ContactRowView(contact: contact)
                    }
                }

                Spacer(minLength: 0)

                BottomTabBar(selected: $selectedTab)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 18)
        }
    }

    private var background: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: 0xCEECE1), location: 0.00),
                .init(color: Color(hex: 0xE6EBF7), location: 0.55),
                .init(color: Color(hex: 0xF3F4F8), location: 1.00),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Models

struct UpdateCard: Identifiable {
    let id = UUID()
    let avatarAsset: String
    let name: String
    let time: String
    let message: String
}

struct ShareContact: Identifiable {
    let id = UUID()
    let avatarAsset: String
    let name: String
    let relation: String
    let moodAsset: String
}

// MARK: - Components

private struct UpdateCardView: View {
    let item: UpdateCard

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(hex: 0x5E62A3))
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 10)

            // Watermark (your mock has a big faint heart/shape).
            // If your exported watermark SVG is named "Image", this will use it.
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .opacity(0.22)
                .offset(x: 20, y: 22)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    AssetIcon(name: item.avatarAsset)
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text(item.time)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Spacer()
                }

                Text(item.message)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(2)

                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .frame(width: 300, height: 160)
    }
}

private struct ContactRowView: View {
    let contact: ShareContact

    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)

            // Big mood face (cropped off the right edge like your mock)
            Image(contact.moodAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .offset(y: 10)

            HStack(spacing: 14) {
                AssetIcon(name: contact.avatarAsset)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.88))

                    Text(contact.relation)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.55))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct BottomTabBar: View {
    @Binding var selected: SharingView.Tab

    var body: some View {
        HStack(spacing: 26) {
            tab(.home)
            tab(.sharing)
            tab(.vitals)
            tab(.explore)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 22)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.92))
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
    }

    private func tab(_ tab: SharingView.Tab) -> some View {
        Button {
            selected = tab
        } label: {
            Image(systemName: tab.sf)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    selected == tab
                    ? Color("AccentColor")
                    : Color("AccentColor").opacity(0.55)
                )
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Asset helper

/// If your SVGs are in Assets.xcassets, `Image(name)` will work.
/// (If it *doesn't* render: you either need to import them as PDF vectors,
/// or use an SVG renderer like SVGKit/SwiftSVG.)
private struct AssetIcon: View {
    let name: String

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .accessibilityLabel(Text(name))
    }
}

// MARK: - Utilities

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

#Preview {
    SharingView()
        .preferredColorScheme(.light)
}
