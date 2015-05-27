//
//  DeviceInfo.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import Foundation

public class Device {
    var address: String
    var passkey: String
    
    static var SERVICE_UUID = "FFF0"
    static var SWITCH_STATE_UUID = "FFF1"
    static var CONTROL_MODE_UUID = "FFF2"
    static var TEMPERATURE_UUID = "FFF3"
    static var TEMPERATURE_RANGE_UUID = "FFF4"
    
    init (address: String, passkey: String) {
        self.address = address
        self.passkey = passkey
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
    
    class func initFromUrl(url: String) {
    }
    
    class func decodeDeviceInfoString(infoString: String) {
    }
    
    // encode the last 20bits of a given mac address to a 4-character base32-encoded string
    public class func getBase32ShortAddress(addr: String)-> String {
        var addr = addr;
        addr = addr.substringFromIndex(advance(addr.endIndex, -7))
        addr = addr.stringByReplacingOccurrencesOfString(":", withString: "", options: nil, range: nil)
        
        let hex = Array("0123456789ABCDEF")
        var values = [Int]()
        
        for char in addr {
            values.append(find(hex, char)!)
        }
        
        let base32 = Array("abcdefghijklmnopqrstuvwxyz234567")
        
        var name = [Int]()
        name.append((values[0] << 1) + ((values[1] & 0x8) >> 7))
        name.append(((values[1] & 0x0F) << 2) + ((values[2] & 0x08) >> 2))
        name.append(((values[2] & 0x03) << 3) + (values[3] & 0x0E) >> 1)
        name.append(((values[3] & 0x01) << 4) + values[4])
        
        var a = ""
        for n in name {
            a += String(base32[n])
        }
        return a
    }
}