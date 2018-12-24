//
//  BluetoothDevice.swift
//  SmoothQ
//
//  Created by Jesus Lopez Garcia on 23/12/2018.
//  Copyright © 2018 Jesus Lopez Garcia. All rights reserved.
//

import Cocoa
import CoreBluetooth

class BluetoothDevice {
    var name:String?
    var uuid:String
    var device:CBPeripheral
    var services:[CBService]?
    
    init(_ peripheral: CBPeripheral) {
        name = peripheral.name
        uuid = peripheral.identifier.uuidString
        device = peripheral
    }
}
