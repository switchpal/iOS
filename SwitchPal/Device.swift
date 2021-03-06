//
//  DeviceInfo.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import Foundation

public class Device {
    public var address: String
    public var passkey: String
    
    public var temperature: Float
    public var temperatureRangeMin: Float
    public var temperatureRangeMax: Float
    public var controlMode: Bool!
    public var switchState: Bool!
    
    static var SERVICE_UUID = "FFF0"
    static var SWITCH_STATE_UUID = "FFF1"
    static var CONTROL_MODE_UUID = "FFF2"
    static var TEMPERATURE_UUID = "FFF3"
    static var TEMPERATURE_RANGE_UUID = "FFF4"
    
    init (address: String, passkey: String) {
        self.address = address
        self.passkey = passkey
        
        self.temperature = 0
        self.temperatureRangeMin = 0;
        self.temperatureRangeMax = 0;
        self.controlMode = nil
        self.switchState = nil
    }
    
    func getName() -> String {
        return "SwitchPal-" + Device.getBase32ShortAddress(self.address)
    }
    
    // decode temperature in NSData received from the bluetooth device
    public class func decodeTemperature(data: NSData) -> Float {
        var integerPart = 0
        var fractionPart = 0
        data.getBytes(&integerPart, length: 1)
        data.getBytes(&fractionPart, range: NSMakeRange(1, 1))
        return Float(integerPart) + 0.01 * Float(fractionPart)
    }
    
    public class func decodeTemperatureRange(data: NSData) -> (Float, Float) {
        let data1 = data.subdataWithRange(NSMakeRange(0, 2))
        let data2 = data.subdataWithRange(NSMakeRange(2, 2))
        return (decodeTemperature(data1), decodeTemperature(data2))
    }
    
    public func encodeTemperatureRange() -> NSData {
        let min = temperatureRangeMin
        let max = temperatureRangeMax
        
        var bytes: [UInt8] = []
        bytes.append(UInt8(min))
        bytes.append(UInt8((min - Float(Int(min)))*100))
        bytes.append(UInt8(max))
        bytes.append(UInt8((max - Float(Int(max)))*100))
        
        return NSData(bytes: bytes, length: bytes.count)
    }
    
    public class func decodeBool(data: NSData) -> Bool {
        var char = 0x00
        data.getBytes(&char, length: 1)
        return char != 0
    }
    
    // 
    public class func initFromUrl(url: String) -> Device? {
        func getQueryStringParameter(url: String, param: String) -> String? {
            let url = NSURLComponents(string: url)!
            return (url.queryItems!).filter({ (item) in item.name == param }).first?.value!
        }
        let infoString = getQueryStringParameter(url, param: "device")
        return Device.decodeDeviceInfoString(infoString!)
    }
    
    public class func initFromDefaults(defaults: NSUserDefaults) -> Device? {
        if let address = defaults.stringForKey("address") {
            if let passkey = defaults.stringForKey("passkey") {
                let device = Device(address: address, passkey: passkey)
                device.switchState = defaults.boolForKey("switchState")
                device.controlMode = defaults.boolForKey("controlMode")
                device.temperature = defaults.floatForKey("temperature")
                device.temperatureRangeMin = defaults.floatForKey("temperatureRangeMin")
                device.temperatureRangeMax = defaults.floatForKey("temperatureRangeMax")
                return device
            }
        }
        return nil
    }
    
    public func writeDefaults(defaults: NSUserDefaults) {
        defaults.setObject(self.address, forKey: "address")
        defaults.setObject(self.passkey, forKey: "passkey")
        if let _ = self.switchState {
            defaults.setBool(self.switchState, forKey: "switchState")
        }
        if let _ = self.controlMode {
            defaults.setBool(self.controlMode, forKey: "controlMode")
        }
        defaults.setFloat(self.temperature, forKey: "temperature")
        defaults.setFloat(self.temperatureRangeMin, forKey: "temperatureRangeMin")
        defaults.setFloat(self.temperatureRangeMax, forKey: "temperatureRangeMax")
        defaults.synchronize()
    }
    
    //
    public class func decodeDeviceInfoString(infoString: String) -> Device {
        let decodedData = NSData(base64EncodedString: infoString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        
        
        var char = 0
        
        // find the address
        var address = ""
        for i in 0...5 {
            decodedData.getBytes(&char, range: NSMakeRange(i, 1))
            address += NSString(format: "%02X", char) as String
            if (i != 5) {
                address += ":"
            }
        }
        
        var passkey = ""
        for i in 6...8 {
            decodedData.getBytes(&char, range: NSMakeRange(i, 1))
            passkey += NSString(format: "%02X", char) as String
        }
        
        return Device(address: address, passkey: passkey)
    }
    
    // encode the last 20bits of a given mac address to a 4-character base32-encoded string
    public class func getBase32ShortAddress(addr: String)-> String {
        var addr = addr;
        addr = addr.substringFromIndex(addr.endIndex.advancedBy(-7))
        addr = addr.stringByReplacingOccurrencesOfString(":", withString: "")
        
        let hex = Array("0123456789ABCDEF".characters)
        var values = [Int]()
        
        for char in addr.characters {
            values.append(hex.indexOf(char)!)
        }
        
        let base32 = "abcdefghijklmnopqrstuvwxyz234567"
        
        var name = [Int]()
        name.append((values[0] << 1) + ((values[1] & 0x8) >> 3))
        name.append(((values[1] & 0x07) << 2) + ((values[2] & 0x08) >> 2))
        name.append(((values[2] & 0x03) << 3) + (values[3] & 0x0E) >> 1)
        name.append(((values[3] & 0x01) << 4) + values[4])
        
        var a = ""
        for n in name {
            a += String(base32[base32.startIndex.advancedBy(n)])
        }
        return a
    }
    
}