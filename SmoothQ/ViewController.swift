//
//  ViewController.swift
//  SmoothQ
//
//  Created by Jesus Lopez Garcia on 23/12/2018.
//  Copyright © 2018 Jesus Lopez Garcia. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController {

    var b:BluetoothHelper?
    
    @IBOutlet weak var devicesTableView: NSTableView!
    @IBOutlet weak var devicesSplitView: NSSplitView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        b = BluetoothHelper()
        b?.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func onScanAction(_ sender: Any) {
        b?.currentState == BluetoothHelper.State.idle ? b?.scan() : b?.stop()
    }
    
}





extension ViewController: BluetoothHelperDelegate {
    func bluetoothHelperDidChangeState(sender: BluetoothHelper, state: BluetoothHelper.State) {
        print(state)
    }
    
    func bluetoothHelperDidDiscoveredDevice(sender: BluetoothHelper, device: BluetoothDevice) {
        print("Found \(device.name ?? "Unkown")")
        devicesTableView.reloadData()
    }
    
    func bluetoothHelperDidDisconverServices(sender: BluetoothHelper, device: BluetoothDevice, services: [CBService]) {
        print("\(services.count) Services discovered \(device.name ?? "_")")
    }
}





extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    private enum CellIdentifier {
        static let DeviceCell = "DeviceCell"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return b?.foundDevices.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let device = b?.foundDevices[row] else {
            return nil
        }
        
        let tableCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier.DeviceCell), owner: nil) as! NSTableCellView
        let textField = tableCell.viewWithTag(1) as! NSTextField
        textField.stringValue = device.name ?? device.uuid
        
        return tableCell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard
            let tableView = notification.object as? NSTableView,
            let selectedDevice = b?.foundDevices[tableView.selectedRow]
            else { return }
        
        b?.connect(device: selectedDevice)
    }
}

