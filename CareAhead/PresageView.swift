import SwiftUI
import AVFoundation
import SmartSpectraSwiftSDK
import SwiftData
import Combine

struct PresageView: View {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var processor = SmartSpectraVitalsProcessor.shared
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    
    // UI State
    @State private var timeLeft = 20
    @State private var isScanning = false
    @State private var showingInsight = false
    
    // Live Data Storage
    @State private var capturedHeartRate: Double = 0.0
    @State private var capturedBreathingRate: Double = 0.0

    // Live trace (captured during scan, displayed on Insights)
    @State private var scanStartTime: Date?
    @State private var scanHeartRateSeries: [LiveMetricPoint] = []
    @State private var scanBreathingRateSeries: [LiveMetricPoint] = []

    @State private var didSaveVitalSign = false
    
    // Face Detection State
    @State private var hasFace: Bool = false

    @State private var didSetupSDK: Bool = false

    private let faceTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: - 1. Custom Camera Feed
            if let frame = processor.imageOutput {
                Image(uiImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
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
                if !isScanning {
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
                if !isScanning {
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
                    .disabled(!hasFace) // Require face
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
        }
        .onAppear { setupSDK() }
        .onDisappear { stopCameraCompletely() }
        .onReceive(faceTimer) { _ in
            // Keep the face badge responsive even if buffers are slow.
            updateFaceStatus()
        }
        .fullScreenCover(isPresented: $showingInsight, onDismiss: {
            resetScan()
        }) {
            GeminiInsightScreen(
                heartRateSeries: scanHeartRateSeries,
                breathingRateSeries: scanBreathingRateSeries
            )
        }
        
        // MARK: - 4. Live Data Loop
        .onChange(of: sdk.metricsBuffer) { oldValue, newBuffer in
            // Always update face status (Silent Recording makes this active immediately)
            updateFaceStatus()
            
            // Only capture Vitals if "Start" has been pressed
            if isScanning, let metrics = newBuffer {
                if let lastPulse = metrics.pulse.rate.last, lastPulse.value > 0 {
                    capturedHeartRate = Double(lastPulse.value)
                    appendLiveSample(value: capturedHeartRate, series: &scanHeartRateSeries)
                }
                if let lastBreath = metrics.breathing.rate.last, lastBreath.value > 0 {
                    capturedBreathingRate = Double(lastBreath.value)
                    appendLiveSample(value: capturedBreathingRate, series: &scanBreathingRateSeries)
                }
            }
        }
    }
    
    // MARK: - Logic
    func setupSDK() {
        guard !didSetupSDK else { return }
        didSetupSDK = true

        // NOTE: Hardcoded key (per request). Consider using Keychain/xcconfig for production.
        sdk.setApiKey("DP31vRLDNV71bzySLqvHCal3WWC4mnjf2sIAl8Xs")
        sdk.setSmartSpectraMode(.continuous)
        sdk.setImageOutputEnabled(true)
        sdk.setCameraPosition(.front)
        
        // CHANGE: Start EVERYTHING immediately.
        // This wakes up the Face Detector so the badge works instantly.
        processor.startProcessing()
        processor.startRecording()
        
        // Configure autofocus after camera starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            configureCameraFocus()
        }
    }
    
    func configureCameraFocus() {
        // Access the camera device and configure autofocus
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            // Enable continuous autofocus
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            // Set focus point to center (where face typically is)
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            
            // Enable auto exposure
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Failed to configure camera focus: \(error)")
        }
    }
    
    func startScan() {
        didSaveVitalSign = false
        capturedHeartRate = 0
        capturedBreathingRate = 0
        timeLeft = 20
        isScanning = true

        scanStartTime = Date()
        scanHeartRateSeries.removeAll()
        scanBreathingRateSeries.removeAll()
        
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
        guard processor.imageOutput != nil else { return }

        if let edge = sdk.edgeMetrics {
            if self.hasFace != edge.hasFace {
                withAnimation { self.hasFace = edge.hasFace }
            }
        } else if hasFace {
            // If edge metrics are temporarily unavailable, don't keep a stale "true".
            withAnimation { self.hasFace = false }
        }
    }
    
    func stopCameraCompletely() {
        // Called when you leave the page
        processor.stopProcessing()
        processor.stopRecording()
        isScanning = false
        hasFace = false
        didSetupSDK = false
    }
    
    func finishScan() {
        // Stop capture and transition to insights
        processor.stopRecording()
        processor.stopProcessing()

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

        isScanning = false
        showingInsight = true
    }
    
    func resetScan() {
        timeLeft = 20
        isScanning = false

        scanStartTime = nil
        scanHeartRateSeries.removeAll()
        scanBreathingRateSeries.removeAll()

        // Turn the engine back on for the next preview
        processor.startProcessing()
        processor.startRecording()
    }

    private func appendLiveSample(value: Double, series: inout [LiveMetricPoint]) {
        guard let scanStartTime else { return }
        let elapsed = Date().timeIntervalSince(scanStartTime)
        series.append(.init(t: elapsed, value: value))

        // Keep only the last ~24 seconds.
        let cutoff = max(0, elapsed - 24)
        if let firstToKeep = series.firstIndex(where: { $0.t >= cutoff }), firstToKeep > 0 {
            series.removeFirst(firstToKeep)
        }
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
