import AVFoundation
import SwiftUI
import CoreBluetooth

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
    private var rssiTimer: Timer?
    private let bluetoothManager = BluetoothManager.shared

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func startMonitoringDistance() {
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let peripheral = self.connectedBeacon else { return }
            peripheral.readRSSI()
        }
    }

    func stopMonitoringDistance() {
        rssiTimer?.invalidate()
        rssiTimer = nil
    }

    func cleanup() {
        stopMonitoringDistance()
        bluetoothManager.reset()
        connectedBeacon = nil
        distance = 0.0
    }

    func calculateDistance(from rssi: Int) -> Double {
        // Constants for the formula
        let txPower = -59 // RSSI at 1 meter
        let n = 2.0 // Path loss exponent (2 for free space)
        
        // Calculate distance using the log-distance path loss model
        let distance = pow(10, (Double(txPower) - Double(rssi)) / (10 * n))
        return max(0.1, min(distance, 10.0)) // Clamp between 0.1m and 10m
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
        
        let newDistance = calculateDistance(from: RSSI.intValue)
        DispatchQueue.main.async {
            self.distance = newDistance
        }
    }
}
