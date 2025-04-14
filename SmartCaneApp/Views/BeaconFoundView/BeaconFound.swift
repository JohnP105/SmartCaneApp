import SwiftUI

struct BeaconFound: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel = BeaconFoundViewModel()

    @State private var voiceState: VoiceState = .idle
    private var navItemsSize: CGFloat = 40 // Now defined here once

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let circleSize = screenWidth * 0.7

        VStack {
            VStack(spacing: 0) {
                // Back Button
                BackNavigationBar(title: "Beacon Found") {
                    viewModel.cleanup()
                    navViewModel.navigate(to: .homeSearch(startInSearchMode: false))
                }

                // Main Content
                VStack(spacing: 40) {

                    // Location Info
                    VStack(spacing: 5) {
                        Text("You are currently")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.9))

                        Text(String(format: "%.1f meters away", viewModel.distance))
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            
                        Text("from beacon")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.9))
                    }
                    .onAppear {
                        viewModel.startMonitoringDistance()
                    }
                    .onDisappear {
                        viewModel.stopMonitoringDistance()
                    }

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
            }

            // Spacer to push the bottom navigation bar to the bottom
            Spacer()

            // Bottom Navigation Bar
            HStack(spacing: 70) {
                NavBarItem(
                    icon: viewModel.voiceState == .myLocation
                        ? AnyView(AnimatedSoundRecognitionIcon())
                        : AnyView(Image(systemName: "location.circle")),
                    label: ["My", "Location"],
                    action: {
                        voiceState = .myLocation
                        viewModel.voiceState = .myLocation
                        viewModel.speak(message: "You are currently in the library", state: .myLocation)
                    }
                )

                NavBarItem(
                    icon: viewModel.voiceState == .aroundMe
                        ? AnyView(AnimatedSoundRecognitionIcon())
                        : AnyView(Image(systemName: "arrow.triangle.branch")),
                    label: ["Around", "Me"],
                    action: {
                        voiceState = .aroundMe
                        viewModel.voiceState = .aroundMe
                        viewModel.speak(message: "You are near room 101", state: .aroundMe)
                    }
                )

                NavBarItem(
                    icon: viewModel.voiceState == .nearbyBeacons
                        ? AnyView(AnimatedSoundRecognitionIcon())
                        : AnyView(Image(systemName: "mappin.and.ellipse")),
                    label: ["Nearby", "Beacons"],
                    action: {
                        voiceState = .nearbyBeacons
                        viewModel.voiceState = .nearbyBeacons
                        viewModel.speak(message: "You are around the entrance", state: .nearbyBeacons)
                    }
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.gray.opacity(0.2))
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.onDisconnect = {
                navViewModel.navigate(to: .beaconDisconnected)
            }
        }
    }
}

// Preview
#Preview {
    BeaconFound()
        .environmentObject(NavigationViewModel())
}
