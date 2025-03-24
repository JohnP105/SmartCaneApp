import SwiftUI
import Foundation

enum SearchState {
    case idle
    case searching
    case success
    case failure
}

class HomeSearchViewModel: ObservableObject {
    @Published var searchState: SearchState = .idle
    private var searchTask: DispatchWorkItem?
    
    init(startInSearchMode: Bool = false) {
        if startInSearchMode {
            startSearching()
        }
    }

    func startSearching() {
        withAnimation {
            searchState = .searching
        }

        // Cancel any existing search task before starting a new one
        searchTask?.cancel()

        let task = DispatchWorkItem {
           // let foundBeacon = Bool.random() // Simulate success or failure
            let foundBeacon = false

            DispatchQueue.main.async {
                withAnimation {
                    self.searchState = foundBeacon ? .success : .failure
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
        searchTask = task
    }

    func stopSearching() {
        withAnimation {
            searchState = .idle
        }
        searchTask?.cancel() // Cancel the pending navigation task
    }
}
