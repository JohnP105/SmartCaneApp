import SwiftUI

struct Home: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let circleSize = screenWidth * 0.75
        
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(1.0)]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()

                    // App Title
                    Text("SmartCane")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                    Spacer()

                    // Clickable SmartCane Icon
                    Button(action: {
                        viewModel.goToSearch()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(1), lineWidth: 5)
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: circleSize, height: circleSize)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)

                            SmartCaneIcon(width: screenWidth * 0.45, height: screenHeight * 0.1)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()

                    // Bluetooth Prompt
                    VStack(spacing: 5) {
                        Text("Find SmartCane beacons near you!")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                        Text("Make sure your device’s Bluetooth is on")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                    .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(.vertical, screenHeight * 0.05)
            }
            .navigationDestination(isPresented: $viewModel.navigateToSearch) {
                Search()
            }
        }
    }
}

// Preview
#Preview {
    Home()
}
