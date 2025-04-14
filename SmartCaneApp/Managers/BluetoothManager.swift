import CoreBluetooth
import SwiftUI

/// A manager class that handles Bluetooth operations for beacon discovery
public class BluetoothManager: NSObject, ObservableObject {
    @Published public var isScanning = false
    @Published public var connectedBeacon: CBPeripheral?
    @Published public var discoveredBeacons: [CBPeripheral] = []
    
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
        centralManager.connect(peripheral, options: nil)
    }
    
    public func disconnect() {
        if let peripheral = connectedBeacon {
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
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "unknown")")
        connectedBeacon = peripheral
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "unknown")")
        connectedBeacon = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "unknown"): \(error?.localizedDescription ?? "unknown error")")
        connectedBeacon = nil
    }
} 
