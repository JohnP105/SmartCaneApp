import AVFoundation
import SwiftUI

// Enum to track the current voice state
enum VoiceState {
    case idle
    case myLocation
    case aroundMe
    case nearbyBeacons
}

class BeaconFoundViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var voiceState: VoiceState = .idle
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
        synthesizer.delegate = self
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
}
