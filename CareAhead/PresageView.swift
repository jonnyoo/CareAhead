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
    @State private var showingInsight = false
    
    // Live Data Storage
    @State private var capturedHeartRate: Double = 0.0
    @State private var capturedBreathingRate: Double = 0.0

    @State private var didSaveVitalSign = false
    
    // Face Detection State
    @State private var hasFace: Bool = false

    // SmartSpectra API Key (stored securely in Keychain)
    @State private var smartSpectraSettings: SmartSpectraSettings = .default
    @State private var isShowingSmartSpectraSettings: Bool = false
    @State private var smartSpectraSettingsError: String = ""
    @State private var didAutoPromptForKey: Bool = false
    
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
                HStack {
                    Spacer()
                    Button {
                        isShowingSmartSpectraSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(10)
                            .background(.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 55)
                }

                if !smartSpectraSettingsError.isEmpty {
                    Text(smartSpectraSettingsError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }

                if !smartSpectraSettings.isValid {
                    VStack(spacing: 8) {
                        Text("SmartSpectra API key required")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Tap the gear icon to add your key.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.top, 12)
                }

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
                    .disabled(!hasFace || !smartSpectraSettings.isValid) // Require face + API key
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
        .onAppear {
            loadSmartSpectraSettings()
            setupSDKIfPossible()

            // If the key isn't present yet, prompt once.
            if !smartSpectraSettings.isValid, !didAutoPromptForKey {
                didAutoPromptForKey = true
                isShowingSmartSpectraSettings = true
            }
        }
        .onDisappear { stopCameraCompletely() }
        .fullScreenCover(isPresented: $showingInsight, onDismiss: {
            resetScan()
        }) {
            GeminiInsightScreen()
        }
        .sheet(isPresented: $isShowingSmartSpectraSettings, onDismiss: {
            saveSmartSpectraSettingsAndRestart()
        }) {
            SmartSpectraSettingsSheet(settings: $smartSpectraSettings)
        }
        
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
    func loadSmartSpectraSettings() {
        do {
            smartSpectraSettings = try SmartSpectraSettingsStore.load()
            smartSpectraSettingsError = ""
        } catch {
            smartSpectraSettings = .default
            smartSpectraSettingsError = error.localizedDescription
        }
    }

    func saveSmartSpectraSettingsAndRestart() {
        do {
            try SmartSpectraSettingsStore.save(smartSpectraSettings)
            smartSpectraSettingsError = ""
        } catch {
            smartSpectraSettingsError = error.localizedDescription
        }

        // Apply key and restart the engine if possible
        setupSDKIfPossible()
    }

    func setupSDKIfPossible() {
        guard smartSpectraSettings.isValid else { return }

        sdk.setApiKey(smartSpectraSettings.apiKey)
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
        // Stop capture and transition to insights
        processor.stopRecording()
        processor.stopProcessing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
    }
    
    func resetScan() {
        timeLeft = 20
        isScanning = false

        // Turn the engine back on for the next preview
        processor.startProcessing()
        processor.startRecording()
    }
}

private struct SmartSpectraSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var settings: SmartSpectraSettings

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("SmartSpectra")) {
                    SecureField("API Key", text: $settings.apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("This key is stored in Keychain on-device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Camera Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                }
            }
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
