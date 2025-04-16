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
    private let bluetoothManager = BluetoothManager.shared
    private var searchTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(startInSearchMode: Bool = false) {
        // Check if already connected to a beacon at initialization
        checkExistingConnection()
        
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
            
        // Subscribe to connected beacon updates
        bluetoothManager.$connectedBeacon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peripheral in
                guard let self = self else { return }
                if peripheral != nil && self.searchState != .success {
                    // A beacon has been connected while we're in this view
                    self.searchState = .success
                    self.stopSearching()
                }
            }
            .store(in: &cancellables)
    }
    
    func checkExistingConnection() {
        // If we already have a connected beacon when the view appears, 
        // immediately show as successful
        if let connectedBeacon = bluetoothManager.connectedBeacon {
            print("\n=== EXISTING BEACON CONNECTION DETECTED ===")
            print("Name: \(connectedBeacon.name ?? "Unknown")")
            print("Setting search state to success")
            searchState = .success
        } else {
            print("\n=== NO EXISTING BEACON CONNECTION ===")
        }
    }

    func startSearching() {
        // Check if a beacon is already connected before starting search
        if bluetoothManager.connectedBeacon != nil {
            searchState = .success
            return
        }
        
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
        cancellables.removeAll()
    }
}
