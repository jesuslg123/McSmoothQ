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
    func bluetoothHelperDidDiscoveredDevice(sender: BluetoothHelper, device: CBPeripheral)
    func bluetoothHelperDidDiscoverServices(sender: BluetoothHelper, device: CBPeripheral, services: [CBService])
    func bluetoothHelperDidDiscoverCharacteristics(sender: BluetoothHelper, device: CBPeripheral)
}

class BluetoothHelper: NSObject {
    
    enum State {
        case scanning
        case idle
    }
    
    var bCentralManager: CBCentralManager!
    var foundDevices = [CBPeripheral]()
    var currentState:State = .idle {
        didSet {
            delegate?.bluetoothHelperDidChangeState(sender: self, state: currentState)
        }
    }
    
    var delegate: BluetoothHelperDelegate?
    
    let group = DispatchGroup()
    
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
    
    
    func connect(device: CBPeripheral) {
        bCentralManager.connect(device, options: nil)
    }
    
    func disconnect(device: CBPeripheral) {
        bCentralManager.cancelPeripheralConnection(device)
    }
    
    func discoverServices(device: CBPeripheral) {
        device.delegate = self
        device.discoverServices(nil)
    }
    
    func discoverCharacteristics(device: CBPeripheral) {
        guard let services = device.services else { return }
        
        for _ in services {
            //print("ENTER")
            group.enter()
        }
        
        group.notify(queue: .main) {
            print("DONE")
            self.delegate?.bluetoothHelperDidDiscoverCharacteristics(sender: self, device: device)
        }
        
        for service in services {
            device.discoverCharacteristics(nil, for: service)
        }
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
        
        //let device = BluetoothDevice(peripheral)
        
        let alreadySaved = foundDevices.contains {
                $0.name == peripheral.name
             && $0.identifier == peripheral.identifier
        }
        
        if (!alreadySaved) {
            foundDevices.append(peripheral)
            delegate?.bluetoothHelperDidDiscoveredDevice(sender: self, device: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected device \(peripheral)")
        discoverServices(device: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        delegate?.bluetoothHelperDidDiscoverServices(sender: self, device: peripheral, services: services)
        discoverCharacteristics(device: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //guard let characteristics = service.characteristics else { return }
        //print(characteristics)
        group.leave()
    }
    
}
