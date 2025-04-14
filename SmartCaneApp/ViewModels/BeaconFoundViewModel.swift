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
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private let bluetoothManager = BluetoothManager.shared
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        synthesizer.delegate = self
        
        // Subscribe to RSSI updates
        bluetoothManager.$currentRSSI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rssi in
                guard let self = self else { return }
                self.distance = self.calculateDistance(from: rssi)
            }
            .store(in: &cancellables)
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
        bluetoothManager.reset()
        connectedBeacon = nil
        distance = 0.0
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
        // Reset the connection state
        connectedBeacon = nil
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
