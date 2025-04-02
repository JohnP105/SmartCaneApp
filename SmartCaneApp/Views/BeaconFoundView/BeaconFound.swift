import SwiftUI

struct AnimatedSoundRecognitionIcon: View {
    @State private var isPulsing = false

    var body: some View {
        Image(systemName: "waveform.path.ecg") // You can use a custom icon here
            .resizable()
            .scaledToFit()
            .font(.system(size: 45))
            .frame(height: 45)
            .foregroundColor(.blue)
            .opacity(isPulsing ? 1.0 : 0.7)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .animation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing.toggle()
            }

    }
}

struct BeaconFound: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel = BeaconFoundViewModel()
    
    @State private var voiceState: VoiceState = .idle

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let circleSize = screenWidth * 0.7

        VStack {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 65) {
                    // Close Button ("X" to go back)
                    HStack {
                        Spacer()
                        Button(action: {
                            navViewModel.navigate(to: .homeSearch(startInSearchMode: false))
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                )
                        }
                        .padding(.trailing, 20)
                    }

                    // Location Info
                    VStack(spacing: 5) {
                        Text("You are currently in the")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.9))

                        Text("Library")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .frame(height: 80)

                    // SmartCane Icon Inside a Circle
                    ZStack {
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.65))
                                    .frame(width: circleSize, height: circleSize)
                                SmartCaneIcon()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .task {
                            try? await Task.sleep(nanoseconds: 200_000_000)
                        }
                        .allowsHitTesting(false)
                    }
                }
                .padding(.bottom, 80) // Ensures proper spacing above nav bar
            }

            // Bottom Navigation Bar - Always Fixed at the Bottom
            HStack {
                NavBarItem(
                    icon: viewModel.voiceState == .myLocation
                        ? AnyView(AnimatedSoundRecognitionIcon())
                        : AnyView(Image(systemName: "location.circle")
                            .font(.system(size: 45))
                            .frame(height: 45))
                    ,
                    label: ["My", "Location"],
                    action: {
                        voiceState = .myLocation
                        viewModel.speak(message: "You are currently in the library", state: .myLocation)
                    }
                )
                .frame(maxWidth: .infinity)

                NavBarItem(
                    icon: viewModel.voiceState == .aroundMe
                        ? AnyView(AnimatedSoundRecognitionIcon())
                        : AnyView(Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 45))
                            .frame(height: 45))
                    ,
                    label: ["Around", "Me"],
                    action: {
                        voiceState = .aroundMe
                        viewModel.speak(message: "You are near room 101", state: .aroundMe)
                    }
                )
                .frame(maxWidth: .infinity)

                NavBarItem(
                    icon: viewModel.voiceState == .nearbyBeacons
                        ? AnyView(AnimatedSoundRecognitionIcon())
                        : AnyView(Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 45))
                            .frame(height: 45))
                    ,
                    label: ["Nearby", "Beacons"],
                    action: {
                        voiceState = .nearbyBeacons
                        viewModel.speak(message: "You are around the entrance", state: .nearbyBeacons)
                    }
                )
                .frame(maxWidth: .infinity)
            }
            .frame(height: 70)
            .padding(.top, 25)
            .background(Color.gray.opacity(0.2))


        }
        .navigationBarBackButtonHidden(true)
    }
}

// Preview
#Preview {
    BeaconFound()
        .environmentObject(NavigationViewModel())
}
