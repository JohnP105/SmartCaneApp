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
            // Close Button ("X" to go back) - Only in Search Mode
            if viewModel.searchState == .searching {
                Button(action: {
                    viewModel.stopSearching()
                    animateRipple = false
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
                .position(x: screenWidth - 50, y: screenHeight / 20)
            }
        
            VStack(spacing: 65) {
                
                // App Title & Searching Indicator
                ZStack {
                    if viewModel.searchState == .idle {
                        Text("SmartCane")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    } else if viewModel.searchState == .searching {
                        // Animated "Searching..." Text
                        HStack(spacing: 5) {
                            let searchingText = Array("Searching...")
                            ForEach(0..<searchingText.count, id: \.self) { index in
                                Text(String(searchingText[index]))
                                    .font(.system(size: 35, weight: .semibold))
                                    .foregroundColor(searchingText[index] == "." ? .gray : .black)
                                    .scaleEffect(animateDots ? 1.2 : 1)
                                    .opacity(animateDots ? 0.3 : 1)
                                    .animation(Animation.easeInOut(duration: 0.65).repeatForever().delay(Double(index) * 0.1), value: animateDots)
                            }
                        }
                        .task {
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            animateDots = true
                        }
                           
                    }
                }
                .frame(height: 50)


                ZStack {
                    Button(action: {
                        if viewModel.searchState == .idle {
                            viewModel.startSearching()
                            animateRipple = true
                            animateDots = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.65))
                                .frame(width: animateCircle ? circleSize * 1.2 : circleSize,
                                       height: animateCircle ? circleSize * 1.2 : circleSize)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateCircle)

                            SmartCaneIcon()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.searchState == .searching)
                    .task {
                        try? await Task.sleep(nanoseconds: 200_000_000)
                        animateCircle = true
                    }

                    .background(
                        ZStack {
                            if viewModel.searchState == .searching {
                                ForEach(0..<4, id: \.self) { index in
                                    Circle()
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                        .frame(width: circleSize * (1.5 + CGFloat(index) * 0.5),
                                               height: circleSize * (1.5 + CGFloat(index) * 0.5))
                                        .scaleEffect(animateRipple ? 1.3 : 1)
                                        .opacity(animateRipple ? 0 : 1)
                                        .animation(Animation.easeOut(duration: 1.5).repeatForever().delay(Double(index) * 0.3), value: animateRipple)
                                }
                                .onAppear { animateRipple = true }
                            }
                        }
                        .allowsHitTesting(false)
                    )
                }
                .frame(height: 350) 
                

                VStack(spacing: 5) {
                    Text(viewModel.searchState == .searching ? "Please wait while we find beacons" : "Find SmartCane beacons near you!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black.opacity(0.9))

                    Text("Make sure your device’s Bluetooth is on")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray.opacity(0.85))
                }
                .frame(height: 40)
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
