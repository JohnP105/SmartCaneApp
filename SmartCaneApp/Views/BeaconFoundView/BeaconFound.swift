import SwiftUI

struct BeaconFound: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel = BeaconFoundViewModel()

    @State private var voiceState: VoiceState = .idle
    @State private var animateDots = false
    @State private var animateCircle = false
    @State private var animateRipple = false
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
                        if viewModel.isAttemptingReconnection {
                            HStack(spacing: 5) {
                                let reconnectingText = Array("Reconnecting...")
                                ForEach(0..<reconnectingText.count, id: \.self) { index in
                                    Text(String(reconnectingText[index]))
                                        .font(.system(size: 35, weight: .bold))
                                        .foregroundColor(.orange)
                                        .scaleEffect(animateDots ? 1.2 : 1)
                                        .opacity(animateDots ? 0.3 : 1)
                                        .animation(Animation.easeInOut(duration: 0.65).repeatForever().delay(Double(index) * 0.1), value: animateDots)
                                }
                            }
                            .onAppear {
                                animateDots = true
                            }
                            .onDisappear {
                                animateDots = false
                            }
                            
                        } else {
                            Text("You are")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black.opacity(0.9))
                            
                            Text(String(format: "%.1f meters away", viewModel.distance))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .transition(.opacity)
                        }
                    }
                    .frame(height: 50) // Fixed height to prevent layout shifts during reconnecting mode
                    .animation(.easeInOut, value: viewModel.isAttemptingReconnection)
                    .onAppear {
                        viewModel.startMonitoringDistance()
                    }
                    .onDisappear {
                        viewModel.stopMonitoringDistance()
                    }

                    // SmartCane Icon Inside a Circle
                    ZStack {
                        // Only create animations when reconnecting
                        if viewModel.isAttemptingReconnection {
                            // Orange animating circle with ripple effect during reconnection
                            Circle()
                                .fill(Color.orange.opacity(0.65))
                                .frame(width: animateCircle ? circleSize * 1.2 : circleSize,
                                       height: animateCircle ? circleSize * 1.2 : circleSize)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateCircle)
                                
                            // Ripple effect
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                                    .frame(width: circleSize * (1.5 + CGFloat(index) * 0.5),
                                           height: circleSize * (1.5 + CGFloat(index) * 0.5))
                                    .scaleEffect(animateRipple ? 1.3 : 1)
                                    .opacity(animateRipple ? 0 : 1)
                                    .animation(Animation.easeOut(duration: 1.5).repeatForever().delay(Double(index) * 0.3), value: animateRipple)
                            }
                            
                            // SmartCane icon on top
                            SmartCaneIcon()
                                .onAppear {
                                    animateCircle = true
                                    animateRipple = true
                                }
                                .onDisappear {
                                    animateCircle = false
                                    animateRipple = false
                                }
                        } else {
                            // Static blue circle when not reconnecting
                            Circle()
                                .fill(Color.blue.opacity(0.65))
                                .frame(width: circleSize, height: circleSize)
                                
                            // SmartCane icon on top
                            SmartCaneIcon()
                        }
                    }
                    .frame(height: 350)
                }
            }

            // Spacer to push the bottom navigation bar to the bottom
            Spacer()

            // Bottom Navigation Bar - disabled during reconnection
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
                .disabled(viewModel.isAttemptingReconnection)
                .opacity(viewModel.isAttemptingReconnection ? 0.5 : 1.0)

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
                .disabled(viewModel.isAttemptingReconnection)
                .opacity(viewModel.isAttemptingReconnection ? 0.5 : 1.0)

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
                .disabled(viewModel.isAttemptingReconnection)
                .opacity(viewModel.isAttemptingReconnection ? 0.5 : 1.0)
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
