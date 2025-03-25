import SwiftUI

struct BeaconFound: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel = BeaconFoundViewModel()

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let circleSize = UIScreen.main.bounds.width * 0.7
        
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)

            // Close Button ("X" to go back)
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
            .position(x: screenWidth - 50, y: screenHeight / 20)

        
            VStack(spacing: 65) {
                
                // App Title & Searching Indicator
                
                
                ZStack {
                    VStack(spacing: 5) {
                        Text("You are currently in the")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.9))

                        Text("Library")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .frame(height: 80)


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

                VStack(spacing: 5) {
                    Text("")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black.opacity(0.9))

                    Text("")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray.opacity(0.85))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// Preview
#Preview {
    BeaconFound()
        .environmentObject(NavigationViewModel())
}
