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
    @AppStorage("shouldFindBeacon") private var shouldFindBeacon: Bool = false // Persistent across app restarts
    
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

        searchTask?.cancel()
        searchTask = nil

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                withAnimation {
                    self.searchState = self.shouldFindBeacon ? .success : .failure
                    self.shouldFindBeacon.toggle() // Alternate result
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: task)
        searchTask = task
    }

    func stopSearching() {
        searchTask?.cancel()
        searchTask = nil

        withAnimation {
            searchState = .idle
        }
    }
}
