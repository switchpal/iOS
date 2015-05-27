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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
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
        if peripheral.name == "SwitchPal" {
            centralManager.stopScan()
            self.peripheral = peripheral
            peripheral.description
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("state: \(central.state)")
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
