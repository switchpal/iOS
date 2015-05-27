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
    
}
