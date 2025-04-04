import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navViewModel: NavigationViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                switch navViewModel.currentScreen {
                case .homeSearch(let startInSearchMode):
                    HomeSearch(startInSearchMode: startInSearchMode)
                        .transition(.asymmetric(
                            insertion: .opacity, // Home fades in without movement
                            removal: .opacity // Home fades out without movement
                        ))

                    
                case .beaconNotFound:
                    BeaconNotFound()
                        .transition(.move(edge: .trailing)) // Slide in from right
                
                case .beaconFound:
                    BeaconFound()
                        .transition(.move(edge: .trailing)) // Slide in from right
                
                case nil:
                    Text("Loading...")
                        .transition(.opacity) // Fade in while loading
                }
            }
            .animation(.easeInOut(duration: 0.5), value: navViewModel.currentScreen) // Animate transitions
        }
    }
}

// Preview
#Preview {
    ContentView()
        .environmentObject(NavigationViewModel()) // Provide a mock instance
}
