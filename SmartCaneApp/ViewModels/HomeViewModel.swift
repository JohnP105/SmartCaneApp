import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var navigateToSearch = false

    func goToSearch() {
        navigateToSearch = true
    }
}
