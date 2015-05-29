//
//  DeviceTests.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 27/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//


import UIKit
import XCTest
import SwitchPal

class DeviceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetBase32ShortName() {
        // This is an example of a functional test case.
        let addr = "00:18:31:F1:68:C0"
        let name = Device.getBase32ShortAddress(addr)
        XCTAssert(name == "c2ga", "Pass")
    }
    
    func testDecodeTemperature() {
        var a = 0x061a
        let data = NSData(bytes: &a, length: 2)
        let temp = Device.decodeTemperature(data)
        XCTAssert(temp-26.06<0.01, "Pass")
    }
    
    func testDecodeInfoString() {
        let str = "ZNJW59nKFChX"
        let device = Device.decodeDeviceInfoString(str)
        XCTAssert(device.address == "64:D2:56:E7:D9:CA", "Address")
        XCTAssert(device.passkey == "142857", "Passkey")
    }
    
    func testInitFromUrl() {
        let str = "http://getswitchpal.com/app/?device=ZNJW59nKFChX"
        let device = Device.initFromUrl(str)
        XCTAssert(device.address == "64:D2:56:E7:D9:CA", "Address")
        XCTAssert(device.passkey == "142857", "Passkey")
    }
}
