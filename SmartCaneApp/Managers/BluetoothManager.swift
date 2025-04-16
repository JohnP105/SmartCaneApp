import CoreBluetooth
import SwiftUI

/// A manager class that handles Bluetooth operations for beacon discovery
public class BluetoothManager: NSObject, ObservableObject {
    public static let shared = BluetoothManager()
    @Published public var isScanning = false
    @Published public var connectedBeacon: CBPeripheral?
    @Published public var discoveredBeacons: [CBPeripheral] = []
    @Published public var currentRSSI: Int = 0
    
    // Keep track of the last connected peripheral for reconnection purposes
    private var lastConnectedPeripheralId: UUID?
    // Keep track of peripherals we're attempting to connect to
    private var connectingPeripherals: [UUID: CBPeripheral] = [:]
    
    private var centralManager: CBCentralManager!
    private let centralManagerQueue = DispatchQueue(label: "com.smartcane.bluetooth", qos: .userInitiated)
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    public func startScanning(forReconnect: Bool = false) {
        guard centralManager.state == .poweredOn else { return }
        
        isScanning = true
        
        // If scanning for a specific beacon that was previously connected, log the ID
        if forReconnect, let lastId = lastConnectedPeripheralId {
            print("\n=== SCANNING FOR SPECIFIC BEACON ===")
            print("Last Connected ID: \(lastId)")
        }
        
        // Scan for all beacons
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ])
    }
    
    public func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    public func connect(to peripheral: CBPeripheral) {
        print("\n=== CONNECTING TO BEACON ===")
        print("Name: \(peripheral.name ?? "Unknown")")
        print("Identifier: \(peripheral.identifier)")
        
        // Add to connecting peripherals to maintain a strong reference while connecting
        connectingPeripherals[peripheral.identifier] = peripheral
        
        // Set the delegate before connecting
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    public func disconnect() {
        if let peripheral = connectedBeacon {
            print("\n=== DISCONNECTING FROM BEACON ===")
            print("Name: \(peripheral.name ?? "Unknown")")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    public func reset() {
        print("\n=== RESETTING BLUETOOTH MANAGER ===")
        // Disconnect current beacon if any
        if let peripheral = connectedBeacon {
            print("Disconnecting from: \(peripheral.name ?? "Unknown")")
            centralManager.cancelPeripheralConnection(peripheral)
        }
        // Clear discovered beacons
        discoveredBeacons.removeAll()
        // Stop scanning
        stopScanning()
        // Reset connection state
        connectedBeacon = nil
        // Clear connecting peripherals
        connectingPeripherals.removeAll()
        // Reset RSSI value
        currentRSSI = 0
        print("Bluetooth Manager reset complete")
    }
    
    // Retrieve a peripheral by UUID if possible
    public func retrievePeripheral(withIdentifier identifier: UUID) -> CBPeripheral? {
        // First check our connecting peripherals cache
        if let cachedPeripheral = connectingPeripherals[identifier] {
            return cachedPeripheral
        }
        
        // Then try the system method
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
        return peripherals.first
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on")
        } else {
            print("Bluetooth is not available: \(central.state)")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if we're trying to reconnect to a specific device
        if let lastId = lastConnectedPeripheralId, peripheral.identifier == lastId {
            print("\n=== FOUND PREVIOUSLY CONNECTED BEACON ===")
            print("Name: \(peripheral.name ?? "No name")")
            print("Identifier: \(peripheral.identifier)")
            print("RSSI: \(RSSI) dBm")
            
            // Found our previously connected device - attempt to reconnect
            connect(to: peripheral)
            return
        }
        
        // Only process if it's our SmartCane beacon
        if peripheral.name == "SmartCane" {
            print("\n=== SMART CANE BEACON FOUND ===")
            print("Name: \(peripheral.name ?? "No name")")
            print("Identifier: \(peripheral.identifier)")
            print("RSSI: \(RSSI) dBm")
            print("\nAdvertisement Data:")
            advertisementData.forEach { key, value in
                print("- \(key): \(value)")
            }
            print("========================\n")
            
            if !discoveredBeacons.contains(peripheral) {
                discoveredBeacons.append(peripheral)
                // Automatically connect to the first beacon found
                if connectedBeacon == nil {
                    connect(to: peripheral)
                }
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\n=== BEACON CONNECTED ===")
        print("Name: \(peripheral.name ?? "Unknown")")
        // Store the connected peripheral's ID for potential reconnection
        lastConnectedPeripheralId = peripheral.identifier
        connectedBeacon = peripheral
        
        // Remove from connecting peripherals but keep the connected one
        // We don't need it in the connecting cache since it's stored in connectedBeacon
        connectingPeripherals.removeValue(forKey: peripheral.identifier)
        
        // Start reading RSSI immediately after connection
        peripheral.readRSSI()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\n=== BEACON DISCONNECTED ===")
        print("Name: \(peripheral.name ?? "Unknown")")
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        connectedBeacon = nil
        
        // Remove from connecting peripherals if it was there
        connectingPeripherals.removeValue(forKey: peripheral.identifier)
        
        // Don't clear lastConnectedPeripheralId here to facilitate reconnection
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\n=== BEACON CONNECTION FAILED ===")
        print("Name: \(peripheral.name ?? "Unknown")")
        print("Error: \(error?.localizedDescription ?? "unknown error")")
        
        // Clean up the connecting peripheral reference
        connectingPeripherals.removeValue(forKey: peripheral.identifier)
        
        if connectedBeacon?.identifier == peripheral.identifier {
            connectedBeacon = nil
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        
        print("\n=== BEACON RSSI UPDATE ===")
        print("Name: \(peripheral.name ?? "Unknown")")
        print("RSSI: \(RSSI) dBm")
        
        // Update the published RSSI value
        DispatchQueue.main.async { [weak self] in
            self?.currentRSSI = RSSI.intValue
        }
        
        // Schedule next RSSI read
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.connectedBeacon?.readRSSI()
        }
    }
} 
