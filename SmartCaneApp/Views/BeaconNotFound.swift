import SwiftUI

struct BeaconNotFound: View {
    @State private var navigateToHome = false
    @State private var retrySearch = false

    var body: some View {
        ZStack {
            // Close Button ("X" to go back) - Redirect to Home
            Button(action: {
                navigateToHome = true
            }) {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                    )
            }
            .position(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height / 20)

            // Centered VStack
            VStack(spacing: 15) {
                Circle()
                    .fill(Color.blue.opacity(0.9))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )

                Text("No Beacon Found!")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.blue)

                Text("We couldn’t locate any SmartCane Beacon near you")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                
                // Try Again Button
                Button(action: {
                    retrySearch = true
                }) {
                    Text("Try Again")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeSearch(startInSearchMode: false)
        }
        .fullScreenCover(isPresented: $retrySearch) {
            HomeSearch(startInSearchMode: true)
        }
    }
}

// Preview
#Preview {
    BeaconNotFound()
}
