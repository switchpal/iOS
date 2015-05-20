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
    
    init (address: String, passkey: String) {
        self.address = address
        self.passkey = passkey
    }
    
    class func initFromUrl(url: String) {
    }
    
    class func decodeDeviceInfoString(infoString: String) {
    }
}