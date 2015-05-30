//
//  DeviceViewController.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    var device: Device!
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var controlMode: UISwitch!
    @IBOutlet weak var switchState: UISwitch!
    
    var indicator: UIActivityIndicatorView!
    var isOperationInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        //indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        indicator.frame = UIScreen.mainScreen().bounds
        indicator.center = self.view.center
        
        let addr = "00:18:31:F1:68:C0";
        device = Device(address: addr, passkey: "")
        
        // Do any additional setup after loading the view.
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        showProgressOverlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onSwitchStateTouchUpInside(sender: AnyObject) {
        //println("touchUpInside")
        //switchState.enabled = false
        //switchState.userInteractionEnabled = false
        showProgressOverlay()
    }
    
    func showProgressOverlay() {
        isOperationInProgress = true
        self.view.addSubview(indicator)
        indicator.backgroundColor = UIColor.whiteColor()
        indicator.bringSubviewToFront(self.view)
        indicator.startAnimating()
    }
    
    func hideProgressOverlay() {
        if (isOperationInProgress) {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("find a peripheral")
        if peripheral.name == device.getName() {
            println("find the device")
            
            // stop scanning
            centralManager.stopScan()
            
            // must hold the peripheral, or it will be recycled
            // http://stackoverflow.com/a/26379021/693110
            self.peripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: nil)
            println("connecting to the device")
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("connected")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("disconnected")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("fail to connect")
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println("peripheral: didDiscoverServices")
        for service in peripheral.services {
            if let uuid = service.UUID {
                println("uuid: ", uuid.UUIDString)
                if uuid.UUIDString == Device.SERVICE_UUID {
                    println("find service uuid")
                    peripheral.discoverCharacteristics(nil, forService: service as! CBService)
                }
            }
            println("UUID: \(service.UUID)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        println("didDiscoverCharacteristicsForService")
        for characteristic in service.characteristics {
            println("characteristic", characteristic)
            if let uuid = characteristic.UUID {
                println("uuid: ", uuid.UUIDString)
                if uuid.UUIDString == Device.TEMPERATURE_UUID {
                    peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didUpdateValueForCharacteristic")
        switch characteristic.UUID.UUIDString {
        case Device.TEMPERATURE_UUID:
            let temp = Device.decodeTemperature(characteristic.value)
            println("temp: ", temp)
            temperature.text = NSString(format: "%2.1f", temp) as String
            hideProgressOverlay()
        default:
            println("data:", characteristic.value)
            println("unknown characteristic: \(characteristic)")
        }
    }

}
