import SwiftUI

struct BeaconNotFound: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel
    @StateObject private var viewModel = BeaconNotFoundViewModel()

    private let backNavigationFrameHeight = 155
    var body: some View {
        VStack {
            // First Component: Back Arrow Button (Top Left)
            HStack {
                Button(action: {
                    navViewModel.navigate(to: .homeSearch(startInSearchMode: false))
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.white)
                            .background(Color.blue)
                        
                        Text("Back")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Spacer() // Takes up remaining space to keep the button on the left
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background(Color.blue)
            .frame(height: CGFloat(backNavigationFrameHeight))
            .edgesIgnoringSafeArea(.top)
            
            // Second Component: Main Content (Vertically Centered)
            VStack(spacing: 15) {
                Spacer() // Pushes the content down

                Circle()
                    .fill(Color.blue)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )

                Text("No Beacon Found!")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.blue)

                Text("We couldn’t locate any SmartCane Beacon near you")
                    .font(.system(size: 20))
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)

                // Try Again Button
                Button(action: {
                    navViewModel.navigate(to: .homeSearch(startInSearchMode: true))
                }) {
                    Text("Try Again")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Spacer() // Pushes content up to center it vertically
            }
            .padding(.bottom, CGFloat(backNavigationFrameHeight))
            .frame(maxHeight: .infinity) // Makes sure the content takes up the available space
        }
    }
}

// Preview
#Preview {
    BeaconNotFound()
        .environmentObject(NavigationViewModel())
}
