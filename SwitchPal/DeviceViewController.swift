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
    @IBOutlet weak var temperatureRange: UIButton!
    @IBOutlet weak var controlMode: UISwitch!
    @IBOutlet weak var switchState: UISwitch!
    
    var indicator: UIActivityIndicatorView!
    var isOperationInProgress = false
    
    var temperatureCharacteristic: CBCharacteristic!
    var temperatureRangeCharacteristic: CBCharacteristic!
    var controlModeCharacteristic: CBCharacteristic!
    var switchStateCharacteristic: CBCharacteristic!
    
    
    // How does the user come to this ViewController
    // "scan": coming from QRCode, just get the temperature
    // "config": if coming from Temperature config, send user's config to the device
    var fromView: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        //indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        indicator.frame = UIScreen.mainScreen().bounds
        indicator.center = self.view.center
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _device = Device.initFromDefaults(defaults) {
            device = _device
        } else {
            let addr = "00:18:31:F1:68:C0";
            device = Device(address: addr, passkey: "")
        }
        
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
        //showProgressOverlay()
        toggleSwitchState()
    }
    
    @IBAction func onControlModeTouchUpInside(sender: AnyObject) {
        toggleControlMode()
    }
    
    @IBAction func onTemperatureRangeTouchUpInside(sender: AnyObject) {
        self.centralManager.cancelPeripheralConnection(self.peripheral)
        let defaults = NSUserDefaults.standardUserDefaults()
        device.writeDefaults(defaults)
        self.performSegueWithIdentifier("configSegue", sender: self)
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
        for char in service.characteristics {
            println("characteristic", char)
            let characteristic = char as! CBCharacteristic
            if let uuid = characteristic.UUID {
                println("uuid: ", uuid.UUIDString)
                switch uuid.UUIDString {
                case Device.TEMPERATURE_UUID:
                    temperatureCharacteristic = characteristic
                    if self.fromView == nil {
                        peripheral.readValueForCharacteristic(characteristic)
                    }
                case Device.TEMPERATURE_RANGE_UUID:
                    temperatureRangeCharacteristic = characteristic
                    if self.fromView != nil && self.fromView == "config" {
                        let data = NSData()
                        peripheral.writeValue(device.encodeTemperatureRange(), forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
                    }
                case Device.CONTROL_MODE_UUID:
                    controlModeCharacteristic = characteristic
                case Device.SWITCH_STATE_UUID:
                    switchStateCharacteristic = characteristic
                default:
                    println("Unknown characteristics: ", uuid.UUIDString)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didUpdateValueForCharacteristic")
        switch characteristic.UUID.UUIDString {
        case Device.TEMPERATURE_UUID:
            let temp = Device.decodeTemperature(characteristic.value)
            device.temperature = temp
            println("temp: ", temp)
        case Device.SWITCH_STATE_UUID:
            device.switchState = Device.decodeBool(characteristic.value)
        case Device.CONTROL_MODE_UUID:
            device.controlMode = Device.decodeBool(characteristic.value)
        case Device.TEMPERATURE_RANGE_UUID:
            (device.temperatureRangeMin, device.temperatureRangeMax) = Device.decodeTemperatureRange(characteristic.value)
        default:
            println("data:", characteristic.value)
            println("unknown characteristic: \(characteristic)")
        }
        
        updateView()
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didWriteValueForCharacteristic")
        switch characteristic.UUID.UUIDString {
        case Device.SWITCH_STATE_UUID, Device.CONTROL_MODE_UUID, Device.TEMPERATURE_RANGE_UUID:
            // iOS does not return the updated value for the characteristic, so we issue a read request again
            peripheral.readValueForCharacteristic(characteristic)
            //device.switchState = Device.decodeBool(characteristic.value)
        default:
            println("data:", characteristic.value)
            println("unknown characteristic: \(characteristic)")
        }
        //updateView()
    }
    
    func toggleControlMode() {
        
        var char = 0x00
        let currentMode = device.controlMode
        if currentMode != nil && currentMode == true {
            // if current mode is Auto, switch to Manual
            char = 0x00
        } else {
            // if current mode is Manual, or not yet initilized
            char = 0x01
        }
            
        let data = NSData(bytes: &char, length: 1)
        peripheral.writeValue(data, forCharacteristic: controlModeCharacteristic, type:CBCharacteristicWriteType.WithResponse)
        showProgressOverlay()
        
    }
    
    func toggleSwitchState() {
        
        var char = 0x00
        let currentState = device.switchState
        if currentState != nil && currentState == true {
            // if current state is ON, switch to OFF
            char = 0x00
        } else {
            // if current state is OFF, or not yet initialized
            char = 0x01
        }
            
        let data = NSData(bytes: &char, length: 1)
        peripheral.writeValue(data, forCharacteristic: switchStateCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        showProgressOverlay()
    }
    
    func updateView() {
        temperature.text = NSString(format: "%2.1f", device.temperature) as String
        temperatureRange.setTitle(NSString(format: "%2.1f°C/%2.1f°C%", device.temperatureRangeMin, device.temperatureRangeMax) as String, forState: UIControlState.Normal)
        if let state = device.switchState {
            switchState.setOn(state, animated: true)
        }
        if let mode = device.controlMode {
            controlMode.setOn(mode, animated: true)
        }
        hideProgressOverlay()
    }

}
