import SwiftUI

struct BeaconDisconnected: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel

    var body: some View {
        VStack {
            // Back Button
            BackNavigationBar(title: "Beacon Disconnected") {
                navViewModel.navigate(to: .homeSearch(startInSearchMode: false))
            }

            // Main Content
            VStack(spacing: 15) {
                Spacer()

                Circle()
                    .fill(Color.blue)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )

                Text("Beacon Disconnected!")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.blue)

                Text("The connection to your SmartCane Beacon was lost")
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

                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 140)
        }
    }
}

// Preview
#Preview {
    BeaconDisconnected()
        .environmentObject(NavigationViewModel())
} 