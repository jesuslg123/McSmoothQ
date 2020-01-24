//
//  SmoothQManager.swift
//  SmoothQ
//
//  Created by Jesus Lopez Garcia on 24/12/2018.
//  Copyright © 2018 Jesus Lopez Garcia. All rights reserved.
//

import Cocoa
import CoreBluetooth

class SmoothQManager {
    
    enum Direction: String {
        case Up =       "0610010ed449e4"
        case Down =     "061001012c37cd"
        case Left =     "061002012c6e9d"
        case Right =    "0610020ed410b4"
    }
    
    enum Mode: String {
        //0601 2700 00B8 67
        case Locking =      "0681270001757E"
        case PanFollowing = "068127000065 5F"
        case Following =    "0681270002451D"
    }
    
    let device:CBPeripheral
    
    init(peripheral: CBPeripheral) {
        device = peripheral
        //listInfo()
    }
    
    func listInfo() {
        guard let services = device.services else { return }
        
        for service in services {
            print(service)
            for characteristic in service.characteristics! {
                print(characteristic)
                print(characteristic.properties)
                print(characteristic.descriptors!)
                sleep(1)
            }
            sleep(1)
        }
        
        
    }
    
    func mode(mode: Mode) {
        print("\(device.name ?? "Unknown") - MODE \(mode)")
        
        write(string: mode.rawValue)
    }
    
    func move(direction:Direction) {
        print("\(device.name ?? "Unknown") - MOVE \(direction)")
        
        write(string: direction.rawValue)
    }
    
    func write(string: String) {
        print("\(device.name ?? "Unknown") - Write: \(string)")
        
        guard let service = device.services?[2] else { return }
        guard let characteristic = service.characteristics?[0] else { return }

        DispatchQueue.global(qos: .background).async {
            self.write(characteristic: characteristic, data: string.hexadecimal!)
        }
    }
    
    private func write(characteristic: CBCharacteristic, data: Data) {
        device.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
}



extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}
