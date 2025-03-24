import SwiftUI

@main
struct SmartCaneApp: App {
    @StateObject private var navViewModel = NavigationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navViewModel) // Inject the navigation model
        }
    }
}
