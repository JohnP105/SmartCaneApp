import AVFoundation
import SwiftUI

// Enum to track the current voice state
enum VoiceState {
    case idle
    case myLocation
    case aroundMe
    case nearbyBeacons
}

// BeaconFound ViewModel to handle voice synthesis
class BeaconFoundViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {  
    @Published var voiceState: VoiceState = .idle // Initialize with idle state
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init() // Call the superclass initializer
        synthesizer.delegate = self // Set the ViewModel as the delegate for the synthesizer
    }

    // Speak and update voice state
    func speak(message: String, state: VoiceState) {
        voiceState = state // Update the current voice state
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    // Delegate method that is called when speech finishes
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        voiceState = .idle // Reset voice state to idle when speech stops
    }
}
