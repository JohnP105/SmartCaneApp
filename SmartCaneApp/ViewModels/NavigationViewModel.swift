import SwiftUI

enum AppScreen: Hashable {
    case homeSearch(startInSearchMode: Bool = false)
    case beaconFound
    case beaconNotFound
    case beaconDisconnected
}

class NavigationViewModel: ObservableObject {
    @Published var currentScreen: AppScreen? = .homeSearch(startInSearchMode: false)
    private var navigationHistory: [AppScreen] = []

    func navigate(to screen: AppScreen) {
        print("\n=== NAVIGATING ===")
        print("From: \(String(describing: currentScreen))")
        print("To: \(screen)")
        
        // Store current screen in navigation history before changing screens
        // but only if we're not going to HomeSearch from another screen
        if let current = currentScreen {
            let isGoingToHome = isHomeSearchScreen(screen)
            let isFromHome = isHomeSearchScreen(current)
            
            if !(isGoingToHome && !isFromHome) {
                // Don't add to history when going from non-home to home
                navigationHistory.append(current)
            }
        }
        
        self.currentScreen = screen
    }
    
    private func isHomeSearchScreen(_ screen: AppScreen) -> Bool {
        if case .homeSearch = screen {
            return true
        }
        return false
    }
    
    func goBack() {
        if let previousScreen = navigationHistory.popLast() {
            print("\n=== NAVIGATING BACK ===")
            print("From: \(String(describing: currentScreen))")
            print("To: \(previousScreen)")
            self.currentScreen = previousScreen
        }
    }
}
