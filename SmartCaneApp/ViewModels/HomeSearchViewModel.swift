import SwiftUI
import Foundation

class HomeSearchViewModel: ObservableObject {
    @Published var isSearching = false

    // Function to switch to search mode
    func startSearching() {
        withAnimation {
            isSearching = true
        }
        scanForBeacons()
    }

    // Function to return to home mode
    func stopSearching() {
        withAnimation {
            isSearching = false
        }
    }

    // Simulated function for beacon scanning
    private func scanForBeacons() {
        print("Scanning for SmartCane beacons...")
        // TODO: Implement actual Bluetooth scanning logic
    }
}
