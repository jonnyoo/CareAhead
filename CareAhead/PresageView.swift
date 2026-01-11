import SwiftUI
import AVFoundation
import SmartSpectraSwiftSDK
import SwiftData

struct PresageView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var processor = SmartSpectraVitalsProcessor.shared
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    
    // UI State
    @State private var timeLeft = 20
    @State private var isScanning = false
    @State private var scanComplete = false
    
    // Live Data Storage
    @State private var capturedHeartRate: Double = 0.0
    @State private var capturedBreathingRate: Double = 0.0

    @State private var didSaveVitalSign = false
    
    // Face Detection State
    @State private var hasFace: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: - 1. Custom Camera Feed
            if let frame = processor.imageOutput {
                Image(uiImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(x: -1, y: 1) // Mirror effect
            } else {
                VStack {
                    ProgressView()
                        .tint(.white)
                    Text("Starting Camera...")
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
            
            // MARK: - 2. UI Overlay
            VStack {
                // Face Status Indicator (Always Visible now)
                if !scanComplete {
                    HStack {
                        Circle()
                            .fill(hasFace ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        
                        Text(hasFace ? "FACE DETECTED" : "LOOK AT CAMERA")
                            .font(.headline)
                            .foregroundColor(hasFace ? .green : .red)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.black.opacity(0.6))
                            .cornerRadius(20)
                    }
                    .padding(.top, 60)
                }
                
                // Countdown (Only visible when scanning)
                if isScanning {
                    Text("\(timeLeft)s")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .shadow(radius: 4)
                }
                
                Spacer()
                
                // Bottom: Start Button
                if !isScanning && !scanComplete {
                    Button(action: startScan) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(hasFace ? Color.red : Color.gray)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .disabled(!hasFace) // Force user to have face ready
                    .padding(.bottom, 100)
                    
                    Text(hasFace ? "Tap to Start" : "Position Face to Start")
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                        .offset(y: -90)
                    
                } else if isScanning {
                    Text("Hold Still...")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 100)
                }
            }
            
            // MARK: - 3. Results Popup
            if scanComplete {
                Color.black.opacity(0.85).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("Measurement Complete")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    HStack(spacing: 40) {
                        VitalsResultRow(
                            title: "Heart Rate",
                            value: capturedHeartRate > 0 ? "\(Int(capturedHeartRate))" : "--",
                            unit: "BPM"
                        )
                        VitalsResultRow(
                            title: "Breathing",
                            value: capturedBreathingRate > 0 ? "\(Int(capturedBreathingRate))" : "--",
                            unit: "RPM"
                        )
                    }
                    
                    Button(action: resetScan) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
        }
        .onAppear { setupSDK() }
        .onDisappear { stopCameraCompletely() }
        
        // MARK: - 4. Live Data Loop
        .onChange(of: sdk.metricsBuffer) { oldValue, newBuffer in
            // Always update face status (Silent Recording makes this active immediately)
            updateFaceStatus()
            
            // Only capture Vitals if "Start" has been pressed
            if isScanning, let metrics = newBuffer {
                if let lastPulse = metrics.pulse.rate.last, lastPulse.value > 0 {
                    capturedHeartRate = Double(lastPulse.value)
                }
                if let lastBreath = metrics.breathing.rate.last, lastBreath.value > 0 {
                    capturedBreathingRate = Double(lastBreath.value)
                }
            }
        }
    }
    
    // MARK: - Logic
    func setupSDK() {
        let apiKey = "GeiwZOZNRG42wRpGRfatc7bF1J0dYzVs6EQXEl9J"
        sdk.setApiKey(apiKey)
        sdk.setSmartSpectraMode(.continuous)
        sdk.setImageOutputEnabled(true)
        sdk.setCameraPosition(.front)
        
        // CHANGE: Start EVERYTHING immediately.
        // This wakes up the Face Detector so the badge works instantly.
        processor.startProcessing()
        processor.startRecording()
        
        // Backup Timer to ensure face badge updates even if buffer is slow
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.processor.imageOutput == nil { return }
            self.updateFaceStatus()
        }
    }
    
    func startScan() {
        didSaveVitalSign = false
        capturedHeartRate = 0
        capturedBreathingRate = 0
        timeLeft = 20
        isScanning = true
        scanComplete = false
        
        // Note: We don't need to call startRecording() here because it's already running!
        // We just start the countdown.
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                timer.invalidate()
                self.finishScan()
            }
        }
    }
    
    func updateFaceStatus() {
        if let edge = sdk.edgeMetrics {
            if self.hasFace != edge.hasFace {
                withAnimation { self.hasFace = edge.hasFace }
            }
        }
    }
    
    func stopCameraCompletely() {
        // Called when you leave the page
        processor.stopProcessing()
        processor.stopRecording()
        isScanning = false
    }
    
    func finishScan() {
        // We stop recording here so the data "freezes" for the results page
        processor.stopRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { scanComplete = true }

            // Persist today's measurement (so Trends shows Today once a test is done).
            if !didSaveVitalSign,
               capturedHeartRate > 0,
               capturedBreathingRate > 0 {
                let vitalSign = VitalSign(
                    timestamp: Date(),
                    heartRate: Int(capturedHeartRate.rounded()),
                    breathingRate: Int(capturedBreathingRate.rounded())
                )
                modelContext.insert(vitalSign)
                try? modelContext.save()
                didSaveVitalSign = true
            }
        }
    }
    
    func resetScan() {
        scanComplete = false
        timeLeft = 20
        isScanning = false
        
        // Turn the engine back on for the next "Silent Record" preview
        processor.startRecording()
    }
}

struct VitalsResultRow: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title).font(.caption).fontWeight(.semibold).foregroundColor(.gray)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.system(size: 36, weight: .bold)).foregroundColor(.black)
                Text(unit).font(.caption).foregroundColor(.gray)
            }
        }
    }
}
