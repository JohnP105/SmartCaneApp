import SwiftUI

enum AppScreen: Hashable {
    case homeSearch(startInSearchMode: Bool = false)
    case beaconFound
    case beaconNotFound
}

class NavigationViewModel: ObservableObject {
    @Published var currentScreen: AppScreen? = .homeSearch(startInSearchMode: false)

    func navigate(to screen: AppScreen) {
        print("Navigating to: \(screen)")
        DispatchQueue.main.async {
            self.currentScreen = screen
        }
    }

}
