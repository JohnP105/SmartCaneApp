import SwiftUI
import Foundation

class BeaconNotFoundViewModel: ObservableObject {
    @Published var navigateToHome = false
    @Published var retrySearch = false

    // Function to go back to the home screen
    func goToHome() {
        withAnimation {
            navigateToHome = true
        }
    }

    // Function to retry the beacon search
    func retrySearching() {
        withAnimation {
            retrySearch = true
        }
    }
}
