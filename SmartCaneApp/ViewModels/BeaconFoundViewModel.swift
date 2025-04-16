import AVFoundation
import SwiftUI
import CoreBluetooth
import Combine

// Enum to track the current voice state
enum VoiceState {
    case idle
    case myLocation
    case aroundMe
    case nearbyBeacons
}

class BeaconFoundViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var voiceState: VoiceState = .idle
    @Published var connectedBeacon: CBPeripheral?
    @Published var distance: Double = 0.0
    @Published var isAttemptingReconnection: Bool = false
    
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private let bluetoothManager = BluetoothManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 3
    private var reconnectionTimer: Timer?
    private var lastKnownPeripheral: CBPeripheral?
    
    var onDisconnect: (() -> Void)?  // Add callback for disconnection

    override init() {
        super.init()
        synthesizer.delegate = self
        
        // Subscribe to RSSI updates
        bluetoothManager.$currentRSSI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (rssi: Int) in
                guard let self = self else { return }
                self.distance = self.calculateDistance(from: rssi)
            }
            .store(in: &cancellables)
            
        // Subscribe to connection state changes
        bluetoothManager.$connectedBeacon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peripheral in
                guard let self = self else { return }
                
                if peripheral != nil {
                    // Reset reconnection attempts when successfully connected
                    self.reconnectionAttempts = 0
                    self.isAttemptingReconnection = false
                    self.lastKnownPeripheral = peripheral
                    self.invalidateReconnectionTimer()
                } else if self.connectedBeacon != nil && !self.isAttemptingReconnection {
                    // Beacon was disconnected - start reconnection process
                    self.startReconnectionProcess()
                }
                
                self.connectedBeacon = peripheral
            }
            .store(in: &cancellables)
    }
    
    private func startReconnectionProcess() {
        guard reconnectionAttempts < maxReconnectionAttempts else {
            // We've exceeded max attempts, notify disconnect
            print("⚠️ Max reconnection attempts (\(maxReconnectionAttempts)) reached. Giving up.")
            cleanup()
            DispatchQueue.main.async {
                self.onDisconnect?()
            }
            return
        }
        
        reconnectionAttempts += 1
        isAttemptingReconnection = true
        
        print("📶 Attempting to reconnect (Attempt \(reconnectionAttempts)/\(maxReconnectionAttempts))...")
        
        // Start scanning specifically for reconnection
        bluetoothManager.startScanning(forReconnect: true)
        
        // Set a timer for this reconnection attempt
        invalidateReconnectionTimer()
        reconnectionTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // If we're still not connected after the timeout
            if self.bluetoothManager.connectedBeacon == nil {
                print("⏱️ Reconnection attempt \(self.reconnectionAttempts) timed out")
                
                // Stop scanning from this attempt
                self.bluetoothManager.stopScanning()
                
                // Try again or give up
                self.startReconnectionProcess()
            }
        }
    }
    
    private func invalidateReconnectionTimer() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
    }

    func startMonitoringDistance() {
        // No need for timer anymore as BluetoothManager handles RSSI updates
        if let peripheral = bluetoothManager.connectedBeacon {
            peripheral.delegate = bluetoothManager
            peripheral.readRSSI()
        }
    }

    func stopMonitoringDistance() {
        // No need to stop timer as BluetoothManager handles RSSI updates
    }

    func cleanup() {
        invalidateReconnectionTimer()
        bluetoothManager.reset()
        connectedBeacon = nil
        lastKnownPeripheral = nil
        distance = 0.0
        reconnectionAttempts = 0
        isAttemptingReconnection = false
        cancellables.removeAll()
    }

    func calculateDistance(from rssi: Int) -> Double {
        // Constants for the formula
        let txPower = -66 // RSSI at 1 meter
        let n = 2.0 // Path loss exponent (2 for free space)
        
        // Calculate distance using the log-distance path loss model
        let distance = pow(10, (Double(txPower) - Double(rssi)) / (10 * n))
        let clampedDistance = max(0.1, min(distance, 10.0)) // Clamp between 0.1m and 10m
        
        print("\n=== DISTANCE CALCULATION ===")
        print("RSSI: \(rssi) dBm")
        print("Raw Distance: \(String(format: "%.2f", distance)) meters")
        print("Clamped Distance: \(String(format: "%.2f", clampedDistance)) meters")
        print("========================\n")
        
        return clampedDistance
    }

    // Speak and update voice state with click sound and delay
    func speak(message: String, state: VoiceState) {
        voiceState = state // Update the current voice state

        // Stop any ongoing speech immediately
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        // Play a click sound before starting the speech
        playClickSound()

        // Introduce a short delay (e.g., 0.5 seconds) before speaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let utterance = AVSpeechUtterance(string: message)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synthesizer.speak(utterance)
        }
    }

    // Function to play click sound
    private func playClickSound() {
        guard let url = Bundle.main.url(forResource: "click_sound", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing click sound: \(error)")
        }
    }

    // Delegate method that is called when speech finishes
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        voiceState = .idle // Reset voice state to idle when speech stops naturally
    }

    // Delegate method that is called when speech is canceled
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // Reset cancel flag here if needed
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "unknown"): \(error?.localizedDescription ?? "unknown error")")
        // Increment reconnection attempt counter
        reconnectionAttempts += 1
        
        // Try to reconnect if we haven't exceeded max attempts
        if reconnectionAttempts < maxReconnectionAttempts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.bluetoothManager.connect(to: peripheral)
            }
        } else {
            // Reset the connection state
            connectedBeacon = nil
        }
    }

    deinit {
        cleanup()
    }
}

extension BeaconFoundViewModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        
        print("\n=== RSSI UPDATE ===")
        print("Peripheral: \(peripheral.name ?? "Unknown")")
        print("RSSI: \(RSSI) dBm")
        
        let newDistance = calculateDistance(from: RSSI.intValue)
        DispatchQueue.main.async {
            self.distance = newDistance
            print("Updated UI Distance: \(String(format: "%.2f", newDistance)) meters")
            print("========================\n")
        }
    }
}
