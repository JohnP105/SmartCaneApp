import SwiftUI

struct AnimatedSoundRecognitionIcon: View {
    @State private var isPulsing = false

    var body: some View {
        Image(systemName: "waveform.path.ecg")
            .font(.system(size: 45))
            .foregroundColor(.blue)
            .opacity(isPulsing ? 1.0 : 0.7)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .animation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

#Preview {
    AnimatedSoundRecognitionIcon()
}
