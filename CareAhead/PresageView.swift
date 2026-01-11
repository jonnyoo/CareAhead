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
    
    // Optional: toggle for the Face Mesh debug overlay
    @State private var isFaceMeshEnabled = false
    
    init() {
        // MARK: - Basic Configuration
        let apiKey = "GeiwZOZNRG42wRpGRfatc7bF1J0dYzVs6EQXEl9J"
        sdk.setApiKey(apiKey)
        
        // MARK: - Advanced Configuration (Uncomment to use)
        
        // 1. Set the Mode (Continuous = real-time, Spot = fixed window)
        // sdk.setSmartSpectraMode(.continuous)
        // sdk.setSmartSpectraMode(.spot)
        
        // 2. Set Measurement Duration (20.0 - 120.0 seconds)
        // sdk.setMeasurementDuration(30.0)
        
        // 3. Camera Position (Front is recommended for face detection)
        // sdk.setCameraPosition(.front)
        
        // 4. Recording Delay (Countdown before recording starts)
        // sdk.setRecordingDelay(3)
        
        // 5. UI Controls (Show/Hide default UI buttons)
        // sdk.showControlsInScreeningView(true)
        
        // 6. Performance Optimization (Disable image output if running in background)
        // sdk.setImageOutputEnabled(true)
    }
    
    var body: some View {
        ZStack {
            // MARK: - Main Camera View
            // This is the complete UI solution provided by the SDK
            SmartSpectraView()
            
            // MARK: - Face Mesh Overlay (Debug/Advanced)
            // Visualizes the face landmarks used for measurement
            if isFaceMeshEnabled, let edgeMetrics = sdk.edgeMetrics, edgeMetrics.hasFace, !edgeMetrics.face.landmarks.isEmpty {
                if let latestLandmarks = edgeMetrics.face.landmarks.last {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(Array(latestLandmarks.value.enumerated()), id: \.offset) { index, landmark in
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 3, height: 3)
                                    // Map coordinates to the screen (1280x1280 is the normalized space)
                                    .position(
                                        x: CGFloat(landmark.x) * geometry.size.width / 1280.0,
                                        y: CGFloat(landmark.y) * geometry.size.height / 1280.0
                                    )
                            }
                        }
                    }
                    .frame(width: 400, height: 400) // Adjust frame as needed
                }
            }
            
            // Toggle button for Face Mesh
            VStack {
                Spacer()
                Button("Toggle Face Mesh") {
                    isFaceMeshEnabled.toggle()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(.bottom, 50)
            }
        }
        // MARK: - Data Access
        // Monitor the metrics buffer for real-time updates
        // Updated for iOS 17+
        .onChange(of: sdk.metricsBuffer) { oldValue, newBuffer in
            if let metrics = newBuffer {
                // Access Pulse Data
                metrics.pulse.rate.forEach { measurement in
                    print("Pulse: \(measurement.value) BPM at \(measurement.time)s")
                }
                
                // Access Breathing Data
                metrics.breathing.rate.forEach { rate in
                    print("Breathing: \(rate.value) RPM at \(rate.time)s")
                }
            }
        }
    }
}
