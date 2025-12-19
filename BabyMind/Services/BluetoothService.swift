//
//  BluetoothService.swift
//  BabyMind
//
//  Bluetooth cihaz bağlantı servisi
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothService: NSObject, ObservableObject {
    static let shared = BluetoothService()
    
    @Published var isScanning = false
    @Published var discoveredDevices: [BluetoothDevice] = []
    @Published var connectedDevices: [BluetoothDevice] = []
    @Published var bluetoothState: CBManagerState = .unknown
    
    private var centralManager: CBCentralManager!
    private var connectedPeripherals: [CBPeripheral] = []
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth açık değil")
            return
        }
        
        isScanning = true
        discoveredDevices.removeAll()
        
        // Tüm BLE cihazlarını tarayın
        // Belirli bir servis UUID'si varsa, onu belirtebilirsiniz
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func connect(to device: BluetoothDevice) {
        guard let peripheral = device.peripheral else { return }
        
        // Zaten bağlı mı kontrol et
        if connectedDevices.contains(where: { $0.id == device.id }) {
            return
        }
        
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect(from device: BluetoothDevice) {
        guard let peripheral = device.peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        
        connectedDevices.removeAll { $0.id == device.id }
        connectedPeripherals.removeAll { $0 == peripheral }
    }
    
    func disconnectAll() {
        for peripheral in connectedPeripherals {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectedDevices.removeAll()
        connectedPeripherals.removeAll()
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        
        switch central.state {
        case .poweredOn:
            print("Bluetooth açık")
        case .poweredOff:
            print("Bluetooth kapalı")
            stopScanning()
        case .unauthorized:
            print("Bluetooth yetkisi yok")
        case .unsupported:
            print("Bluetooth desteklenmiyor")
        case .resetting:
            print("Bluetooth sıfırlanıyor")
        case .unknown:
            print("Bluetooth durumu bilinmiyor")
        @unknown default:
            print("Bluetooth bilinmeyen durum")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Cihaz zaten keşfedildi mi kontrol et
        if discoveredDevices.contains(where: { $0.peripheral?.identifier == peripheral.identifier }) {
            return
        }
        
        let deviceName = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Bilinmeyen Cihaz"
        
        let device = BluetoothDevice(
            id: peripheral.identifier,
            name: deviceName,
            rssi: RSSI.intValue,
            peripheral: peripheral
        )
        
        DispatchQueue.main.async {
            self.discoveredDevices.append(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bağlandı: \(peripheral.name ?? "Bilinmeyen")")
        
        peripheral.delegate = self
        connectedPeripherals.append(peripheral)
        
        // Servisleri keşfet
        peripheral.discoverServices(nil)
        
        // Bağlı cihazları güncelle
        if let device = discoveredDevices.first(where: { $0.peripheral?.identifier == peripheral.identifier }) {
            var updatedDevice = device
            updatedDevice.isConnected = true
            
            DispatchQueue.main.async {
                if !self.connectedDevices.contains(where: { $0.id == device.id }) {
                    self.connectedDevices.append(updatedDevice)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Bağlantı başarısız: \(peripheral.name ?? "Bilinmeyen") - \(error?.localizedDescription ?? "Bilinmeyen hata")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Bağlantı kesildi: \(peripheral.name ?? "Bilinmeyen")")
        
        connectedPeripherals.removeAll { $0 == peripheral }
        
        DispatchQueue.main.async {
            self.connectedDevices.removeAll { $0.peripheral?.identifier == peripheral.identifier }
            
            // Keşfedilen cihazlar listesini güncelle
            if let index = self.discoveredDevices.firstIndex(where: { $0.peripheral?.identifier == peripheral.identifier }) {
                self.discoveredDevices[index].isConnected = false
            }
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Karakteristik okuma hatası: \(error.localizedDescription)")
            return
        }
        
        // Veri işleme burada yapılabilir
        if let data = characteristic.value {
            print("Veri alındı: \(data.count) byte")
        }
    }
}

// MARK: - BluetoothDevice Model
struct BluetoothDevice: Identifiable, Equatable {
    let id: UUID
    var name: String
    var rssi: Int
    var isConnected: Bool = false
    weak var peripheral: CBPeripheral?
    
    static func == (lhs: BluetoothDevice, rhs: BluetoothDevice) -> Bool {
        lhs.id == rhs.id
    }
    
    var signalStrength: String {
        if rssi >= -50 {
            return "Mükemmel"
        } else if rssi >= -70 {
            return "İyi"
        } else if rssi >= -90 {
            return "Zayıf"
        } else {
            return "Çok Zayıf"
        }
    }
    
    var rssiIcon: String {
        if rssi >= -50 {
            return "wifi"
        } else if rssi >= -70 {
            return "wifi"
        } else if rssi >= -90 {
            return "wifi.exclamationmark"
        } else {
            return "wifi.slash"
        }
    }
}

