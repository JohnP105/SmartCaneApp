import SwiftUI
import Foundation
import CoreBluetooth
import Combine

enum SearchState {
    case idle
    case searching
    case success
    case failure
}

@MainActor
class HomeSearchViewModel: ObservableObject {
    @Published var searchState: SearchState = .idle
    private let bluetoothManager = BluetoothManager()
    private var searchTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(startInSearchMode: Bool = false) {
        if startInSearchMode {
            startSearching()
        }
        
        // Subscribe to bluetooth manager updates
        bluetoothManager.$discoveredBeacons
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (beacons: [CBPeripheral]) in
                guard let self = self else { return }
                if self.searchState == .searching {
                    if !beacons.isEmpty {
                        self.searchState = .success
                        self.stopSearching()
                    }
                }
            }
            .store(in: &cancellables)
    }

    func startSearching() {
        withAnimation {
            searchState = .searching
        }
        
        // Start scanning for beacons
        bluetoothManager.startScanning()
        
        // Set a timeout for beacon search
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.searchState == .searching {
                    self.searchState = .failure
                    self.stopSearching()
                }
            }
        }

    }

    func stopSearching() {
        searchTimer?.invalidate()
        searchTimer = nil
        bluetoothManager.stopScanning()

        withAnimation {
            if searchState == .searching {
                searchState = .idle
            }
        }
    }
    
    deinit {
        searchTimer?.invalidate()
        bluetoothManager.stopScanning()
    }
}
