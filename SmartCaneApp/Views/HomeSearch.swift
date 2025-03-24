import SwiftUI

struct HomeSearch: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel: HomeSearchViewModel

    @State private var animateCircle = false
    @State private var animateRipple = false
    @State private var animateDots = false

    init(startInSearchMode: Bool = false) {
        _viewModel = StateObject(
            wrappedValue: HomeSearchViewModel(startInSearchMode: startInSearchMode)
        )
    }

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let circleSize = UIScreen.main.bounds.width * 0.7
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(1.0)]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)

            // Close Button ("X" to go back) - Only in Search Mode
            if viewModel.searchState == .searching {
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
        
            VStack(spacing: 30) {
                
                // App Title & Searching Indicator (Same Space)
                ZStack {
                    // Idle State: "SmartCane"
                    if viewModel.searchState == .idle {
                        Text("SmartCane")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // Searching State: Dots + "Searching..."
                    else if viewModel.searchState == .searching {
                        VStack(spacing: 35) { // Ensure vertical spacing
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
                            .onAppear { animateDots = true }

                            Text("Searching...")
                                .font(.system(size: 30, weight: .semibold)) // Adjust size if needed
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity) // Ensures the VStack takes full width

                    }
                }
                .frame(height: 80) // Ensures both states take up the same space

                
                ZStack {
                    // SmartCane Button
                    Button(action: {
                        if viewModel.searchState == .idle {
                            viewModel.startSearching()
                            animateRipple = true
                            animateDots = true
                        }
                    }) {
                        ZStack {
                            // Button Shape
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 3)
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: animateCircle ? circleSize * 1.2 : circleSize,
                                       height: animateCircle ? circleSize * 1.2 : circleSize)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateCircle)

                            SmartCaneIcon()
                        }
                        .onAppear { animateCircle = true }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.searchState == .searching)
                    .background(
                        // Ripple Effect as a Background to Avoid Layout Issues
                        ZStack {
                            if viewModel.searchState == .searching {
                                ForEach(0..<4, id: \.self) { index in
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        .frame(width: circleSize * (1.5 + CGFloat(index) * 0.5),
                                               height: circleSize * (1.5 + CGFloat(index) * 0.5))
                                        .scaleEffect(animateRipple ? 1.3 : 1)
                                        .opacity(animateRipple ? 0 : 1)
                                        .animation(Animation.easeOut(duration: 1.5).repeatForever().delay(Double(index) * 0.3), value: animateRipple)
                                }
                                .onAppear { animateRipple = true }
                            }
                        }
                        .allowsHitTesting(false) // Prevents interference with button clicks
                    )
                }

                
                VStack(spacing: 5) {
                    Text(viewModel.searchState == .searching ? "Please wait while we find beacons" : "Find SmartCane beacons near you!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                    Text("Make sure your device’s Bluetooth is on")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                }

            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.searchState) {
            if viewModel.searchState == .success {
                navViewModel.navigate(to: .beaconFound)
            } else if viewModel.searchState == .failure {
                navViewModel.navigate(to: .beaconNotFound)
            }
        }
    }
}

// Preview
#Preview {
    HomeSearch(startInSearchMode: false)
        .environmentObject(NavigationViewModel())
}
