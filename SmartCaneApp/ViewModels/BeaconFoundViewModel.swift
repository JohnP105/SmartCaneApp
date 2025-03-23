import SwiftUI
import Foundation

class BeaconFoundViewModel: ObservableObject {
    @Published var navigateToHome = false

    // Function to go back to the home screen
    func goToHome() {
        withAnimation {
            navigateToHome = true
        }
    }
}
