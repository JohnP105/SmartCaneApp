import SwiftUI
import Foundation

class HomeSearchViewModel: ObservableObject {
    @Published var isSearching: Bool

    init(isSearching: Bool = false) {
        self.isSearching = isSearching
    }

    // Function to switch to search mode
    func startSearching() {
        withAnimation {
            isSearching = true
        }
    }

    // Function to return to home mode
    func stopSearching() {
        withAnimation {
            isSearching = false
        }
    }
}
