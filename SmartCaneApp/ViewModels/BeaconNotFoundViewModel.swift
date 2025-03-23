import SwiftUI
import Foundation

class BeaconNotFoundViewModel: ObservableObject {
    @Published var navigateToHome = false
    
    func goToHome() {
        navigateToHome = true
    }

}
