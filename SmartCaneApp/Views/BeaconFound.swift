import SwiftUI

struct BeaconFound: View {
    @StateObject private var viewModel = BeaconFoundViewModel()

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(1.0)]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // Close Button ("X" to go back) - Redirect to Home
            Button(action: {
                viewModel.goToHome()
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
        .fullScreenCover(isPresented: $viewModel.navigateToHome) {
            HomeSearch(startInSearchMode: false)
        }
    }
}

// Preview
#Preview {
    BeaconFound()
}
