//
//  DeviceInfo.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import Foundation

class DeviceInfo {
    var address: String
    var passkey: String
    
    var SERVICE_UUID = "fff0"
    var SWITCH_STATE_UUID = "fff1"
    var CONTROL_MODE_UUID = "fff2"
    var TEMPERATURE_UUID = "fff3"
    var TEMPERATURE_RANGE_UUID = "fff4"
    
    init (address: String, passkey: String) {
        self.address = address
        self.passkey = passkey
    }
    
    class func initFromUrl(url: String) {
    }
    
    class func decodeDeviceInfoString(infoString: String) {
    }
}