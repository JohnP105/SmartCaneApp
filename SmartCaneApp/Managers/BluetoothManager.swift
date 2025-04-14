import CoreBluetooth
import SwiftUI

/// A manager class that handles Bluetooth operations for beacon discovery
public class BluetoothManager: NSObject, ObservableObject {
    public static let shared = BluetoothManager()
    @Published public var isScanning = false
    @Published public var connectedBeacon: CBPeripheral?
    @Published public var discoveredBeacons: [CBPeripheral] = []
    @Published public var currentRSSI: Int = 0
    
    private var centralManager: CBCentralManager!
    private let centralManagerQueue = DispatchQueue(label: "com.smartcane.bluetooth", qos: .userInitiated)
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: centralManagerQueue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    public func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
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
        // Disconnect current beacon if any
        if let peripheral = connectedBeacon {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        // Clear discovered beacons
        discoveredBeacons.removeAll()
        // Stop scanning
        stopScanning()
        // Reset connection state
        connectedBeacon = nil
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
        connectedBeacon = peripheral
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
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\n=== BEACON CONNECTION FAILED ===")
        print("Name: \(peripheral.name ?? "Unknown")")
        print("Error: \(error?.localizedDescription ?? "unknown error")")
        connectedBeacon = nil
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
