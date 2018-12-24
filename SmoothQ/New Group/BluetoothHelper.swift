//
//  BluetoothHelper.swift
//  SmoothQ
//
//  Created by Jesus Lopez Garcia on 23/12/2018.
//  Copyright © 2018 Jesus Lopez Garcia. All rights reserved.
//

import Cocoa
import CoreBluetooth

protocol BluetoothHelperDelegate {
    func bluetoothHelperDidChangeState(sender: BluetoothHelper, state: BluetoothHelper.State)
    func bluetoothHelperDidDiscoveredDevice(sender: BluetoothHelper, device: BluetoothDevice)
    func bluetoothHelperDidDisconverServices(sender: BluetoothHelper, device: BluetoothDevice, services: [CBService])
}

class BluetoothHelper: NSObject {
    
    enum State {
        case scanning
        case idle
    }
    
    var bCentralManager: CBCentralManager!
    var foundDevices = [BluetoothDevice]()
    var currentState:State = .idle {
        didSet {
            delegate?.bluetoothHelperDidChangeState(sender: self, state: currentState)
        }
    }
    
    var delegate: BluetoothHelperDelegate?
    
    override init() {
        super.init()
        bCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    
    func scan() {
        bCentralManager.scanForPeripherals(withServices: nil)
        currentState = .scanning
    }
    
    func stop() {
        bCentralManager.stopScan()
        currentState = .idle
    }
    
    
    func connect(device: BluetoothDevice) {
        bCentralManager.connect(device.device, options: nil)
    }
    
    func discoverServices(device: BluetoothDevice) {
        device.device.delegate = self
        device.device.discoverServices(nil)
    }
    
    func discoverCharacteristics(device: BluetoothDevice) {
        guard let services = device.device.services else { return }
        
        for service in services {
            device.device.discoverCharacteristics(nil, for: service)
        }
    }
    
    func write(peripheral: CBPeripheral) {
        //let left = "061002012c6e9d"
        //peripheral.writeValue(Data(left), for: <#T##CBCharacteristic#>, type: <#T##CBCharacteristicWriteType#>)
    }
    
    
}


extension BluetoothHelper: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let device = BluetoothDevice(peripheral)
        
        let alreadySaved = foundDevices.contains {
                $0.name == peripheral.name
             && $0.uuid == peripheral.identifier.uuidString
        }
        
        if (!alreadySaved) {
            foundDevices.append(device)
            delegate?.bluetoothHelperDidDiscoveredDevice(sender: self, device: device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected device \(peripheral)")
        
        let device = foundDevices.first {
            $0.name == peripheral.name
                && $0.uuid == peripheral.identifier.uuidString
        }
        
        if let device = device {
            discoverServices(device: device)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        let device = foundDevices.first {
                   $0.name == peripheral.name
                && $0.uuid == peripheral.identifier.uuidString
        }
        
        if let device = device {
            device.services = services
            delegate?.bluetoothHelperDidDisconverServices(sender: self, device: device, services: services)
        }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print(characteristics)
    }
    
}
