//
//  PresageView.swift
//  CareAhead
//
//  Created by Michele Mazzetti on 2026-01-10.
//

import SwiftUI
import SmartSpectraSwiftSDK

struct PresageView: View {
    // 1. Create an observer for the SDK shared instance
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    
    // UI State for Real-Time Readings
    @State private var currentHeartRate: Double = 0.0
    @State private var currentBreathingRate: Double = 0.0
    
    // Optional: toggle for the Face Mesh debug overlay
    @State private var isFaceMeshEnabled = false
    
    init() {
        // MARK: - Basic Configuration
        let apiKey = "GeiwZOZNRG42wRpGRfatc7bF1J0dYzVs6EQXEl9J"
        sdk.setApiKey(apiKey)
        
        // MARK: - Advanced Configuration
        // sdk.setSmartSpectraMode(.continuous)
        // sdk.setMeasurementDuration(30.0)
        // sdk.setCameraPosition(.front)
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Camera Layer (Safe for Canvas)
            #if targetEnvironment(simulator)
                // Fallback for Xcode Canvas / Simulator
                MockSmartSpectraView()
            #else
                // Real SDK for Physical Device
                SmartSpectraView()
            #endif
            
            // MARK: - 2. Face Mesh Overlay (Debug)
            if isFaceMeshEnabled {
                FaceMeshLayer(sdk: sdk)
            }
            
            // MARK: - 3. UI Overlay (Vitals Display)
            VStack {
                Spacer()
                
                // Heart Rate Card
                HStack(spacing: 20) {
                    VitalsCard(
                        title: "HEART RATE",
                        value: "\(Int(currentHeartRate))",
                        unit: "BPM",
                        icon: "heart.fill",
                        color: .red
                    )
                    
                    VitalsCard(
                        title: "BREATHING",
                        value: "\(Int(currentBreathingRate))",
                        unit: "RPM",
                        icon: "wind",
                        color: .blue
                    )
                }
                .padding(.bottom, 20)
                
                // Toggle Button
                Button(action: { isFaceMeshEnabled.toggle() }) {
                    Text(isFaceMeshEnabled ? "Hide Mesh" : "Show Mesh")
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
                .padding(.bottom, 40)
            }
        }
        // MARK: - Data Connection
        // Connects the SDK data stream to our UI variables
        .onChange(of: sdk.metricsBuffer) { oldValue, newBuffer in
            if let metrics = newBuffer {
                // Update Heart Rate (Get last known value)
                if let lastPulse = metrics.pulse.rate.last {
                    currentHeartRate = lastPulse.value
                }
                // Update Breathing Rate
                if let lastBreath = metrics.breathing.rate.last {
                    currentBreathingRate = lastBreath.value
                }
            }
        }
    }
}

// MARK: - Helper Views

// A simulated view so you can design in Canvas without crashing
struct MockSmartSpectraView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Image(systemName: "face.dashed")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .foregroundColor(.gray.opacity(0.5))
                Text("Simulating Camera...")
                    .foregroundColor(.gray)
                    .padding(.top)
            }
        }
    }
}

// Reusable Card Component for Vitals
struct VitalsCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .bottom) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 6)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

// Extracted Face Mesh Logic to keep main view clean
struct FaceMeshLayer: View {
    @ObservedObject var sdk: SmartSpectraSwiftSDK
    
    var body: some View {
        if let edgeMetrics = sdk.edgeMetrics,
           edgeMetrics.hasFace,
           !edgeMetrics.face.landmarks.isEmpty,
           let latestLandmarks = edgeMetrics.face.landmarks.last {
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(latestLandmarks.value.enumerated()), id: \.offset) { index, landmark in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 3, height: 3)
                            .position(
                                x: CGFloat(landmark.x) * geometry.size.width / 1280.0,
                                y: CGFloat(landmark.y) * geometry.size.height / 1280.0
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Preview Logic
#Preview {
    PresageView()
}
