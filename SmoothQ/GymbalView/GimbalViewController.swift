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

    @IBOutlet weak var RawCommandTextField: NSTextField!
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
    
    @IBAction func onFollowingAction(_ sender: Any) {
        smoothQ?.mode(mode: .Following)
    }
    
    @IBAction func onFollowingPanAction(_ sender: Any) {
        smoothQ?.mode(mode: .PanFollowing)
    }
    
    @IBAction func onLockingAction(_ sender: Any) {
        smoothQ?.mode(mode: .Locking)
    }
    
    @IBAction func onRawCMDAction(_ sender: Any) {
        smoothQ?.write(string: RawCommandTextField.stringValue)
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
        case 18:
            smoothQ?.mode(mode: .Following)
        case 19:
            smoothQ?.mode(mode: .Locking)
        case 20:
            smoothQ?.mode(mode: .PanFollowing)
        default:
            return
            
        }
    }
    
}
