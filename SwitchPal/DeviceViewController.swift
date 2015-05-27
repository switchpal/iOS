//
//  DeviceViewController.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController, CBCentralManagerDelegate {

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    var device: Device!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addr = "00:18:31:F1:68:C0";
        device = Device(address: addr, passkey: "")
        
        // Do any additional setup after loading the view.
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //self.peripheral = CBPeripheral
        //self.centralManager.connectPeripheral(self.peripheral, options: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("find a peripheral")
        if peripheral.name == device.getName() {
            println("find the device")
            
            // stop scanning
            centralManager.stopScan()
            
            self.peripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("state: \(central.state.rawValue)")
        
        switch central.state {
        case .PoweredOff:
            println(".PowerOff")
        case .PoweredOn:
            println(".PowerOn")
            // only start the scanning if the bluetooth is ready
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        case .Resetting:
            println(".Resetting")
        case .Unauthorized:
            println(".Unauthorized")
        case .Unknown:
            println(".Unknown")
        case .Unsupported:
            println(".Unsupported")
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("connected")
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("disconnected")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("fail to connect")
    }

}
