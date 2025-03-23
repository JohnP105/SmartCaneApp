import SwiftUI

struct HomeSearch: View {
    @StateObject private var viewModel = HomeSearchViewModel()
    
    // Animations
    @State private var animateCircle = false
    @State private var animateRipple = false
    @State private var animateDots = false

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let circleSize = screenWidth * 0.7
        
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(1.0)]),
                               startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                // Conditionally Render UI for Home or Search Mode
                if !viewModel.isSearching {
                    // Home View
                    Text("SmartCane")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .position(x: screenWidth / 2, y: screenHeight / 7)
                } else {
                    // Search View Title
                    VStack(spacing: 5) {
                        HStack(spacing: 5) {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(animateDots ? 1.4 : 1)
                                    .opacity(animateDots ? 0.1 : 1)
                                    .animation(Animation.easeInOut(duration: 0.65).repeatForever().delay(Double(index) * 0.2), value: animateDots)
                            }
                        }
                        .onAppear {
                            animateDots = true
                        }

                        Text("Searching...")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .multilineTextAlignment(.center)
                    .position(x: screenWidth / 2, y: screenHeight / 6)
                }

                // Centered Clickable SmartCane Icon with Ripple Effect in Search Mode
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let screenHeight = geometry.size.height

                    ZStack {
                        // Ripple Effect (Only in Search Mode)
                        if viewModel.isSearching {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    .frame(width: circleSize * (1.5 + CGFloat(index) * 0.5),
                                           height: circleSize * (1.5 + CGFloat(index) * 0.5))
                                    .scaleEffect(animateRipple ? 1.3 : 1)
                                    .opacity(animateRipple ? 0 : 1)
                                    .animation(Animation.easeOut(duration: 1.5).repeatForever().delay(Double(index) * 0.3), value: animateRipple)
                            }
                            .onAppear {
                                animateRipple = true // Start animation
                            }
                        }

                        // SmartCane Icon with Pulsing Animation
                        Button(action: {
                            if !viewModel.isSearching {
                                viewModel.startSearching()
                                animateRipple = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 3)
                                    .fill(Color.blue.opacity(0.8))
                                    .frame(width: animateCircle ? circleSize * 1.2 : circleSize,
                                           height: animateCircle ? circleSize * 1.2 : circleSize)
                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateCircle)

                                SmartCaneIcon()
                            }
                            .onAppear {
                                animateCircle = true
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewModel.isSearching) // Disable button while searching
                    }
                    .position(x: screenWidth / 2, y: screenHeight / 2)
                }
                .ignoresSafeArea()

                // Description Text (Same for Both Views)
                VStack(spacing: 5) {
                    Text(viewModel.isSearching ? "Please wait while we find beacons" : "Find SmartCane beacons near you!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Text("Make sure your device’s Bluetooth is on")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .multilineTextAlignment(.center)
                .position(x: screenWidth / 2, y: screenHeight * 0.7)

                // Close Button ("X" to go back) - Only in Search Mode
                if viewModel.isSearching {
                    Button(action: {
                        viewModel.stopSearching()
                        animateRipple = false
                    }) {
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .position(x: screenWidth - 50, y: screenHeight / 20)
                }
            }
            .transition(.move(edge: .leading)) // Moves left when switching
            .navigationBarBackButtonHidden(true)
        }
    }
}

// Preview
#Preview {
    HomeSearch()
}
