import AVFoundation
import SwiftUI

class BeaconFoundViewModel: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @EnvironmentObject private var navViewModel: NavigationViewModel

    func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}
