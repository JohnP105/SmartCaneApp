import CoreBluetooth
import SwiftUI

/// A manager class that handles Bluetooth operations for beacon discovery
public class BluetoothManager: NSObject, ObservableObject {
    @Published public var isScanning = false
    @Published public var connectedBeacon: CBPeripheral?
    @Published public var discoveredBeacons: [CBPeripheral] = []
    
    private var centralManager: CBCentralManager!
    private let feasyServiceUUID = CBUUID(string: "D546DF97-4757-47EF-BE09-3E2DCBDD0C77") // Feasy Beacon service UUID
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        centralManager.scanForPeripherals(withServices: [feasyServiceUUID], options: nil)
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
        if !discoveredBeacons.contains(peripheral) {
            discoveredBeacons.append(peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedBeacon = peripheral
        stopScanning()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedBeacon = nil
    }
} 
