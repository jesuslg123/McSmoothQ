//
//  GimbalViewController.swift
//  SmoothQ
//
//  Created by Jesus Lopez Garcia on 24/12/2018.
//  Copyright © 2018 Jesus Lopez Garcia. All rights reserved.
//

import Cocoa
import CoreBluetooth

class GimbalViewController: NSViewController {

    var smoothQ:SmoothQManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        smoothQ?.move(direction: .Up)
        smoothQ?.move(direction: .Up)
        smoothQ?.move(direction: .Up)
        smoothQ?.move(direction: .Up)
        smoothQ?.move(direction: .Up)
        smoothQ?.move(direction: .Up)
    }
    
    func setup(device: CBPeripheral) {
        smoothQ = SmoothQManager(peripheral: device)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)
        switch event.keyCode {
        case 126:
            smoothQ?.move(direction: .Up)
        case 125:
            smoothQ?.move(direction: .Down)
        case 123:
            smoothQ?.move(direction: .Left)
        case 124:
            smoothQ?.move(direction: .Right)
        default:
            return
            
        }
    }
    
}
