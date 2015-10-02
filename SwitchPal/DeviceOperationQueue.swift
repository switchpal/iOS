//
//  DeviceOperationQueue.swift
//  CoolerPal
//
//  Created by Chunliang Lyu on 27/6/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import Foundation
import CoreBluetooth

class DeviceOperationQueue {
    var operations = [DeviceOperation]()
    var current: DeviceOperation? = nil
    var peripheral: CBPeripheral? = nil
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    func add(operation: DeviceOperation) {
        self.operations.append(operation)
        if (current == nil) {
            executeNextIfAny()
        }
    }
    
    func isEmpty() -> Bool {
        return self.operations.isEmpty
    }
    
    func markCurrentDone() {
        self.current = nil
        if (!operations.isEmpty) {
            operations.removeAtIndex(0)
        }
    }
    
    func executeNextIfAny() {
        if (self.current != nil) {
            print("there is still operation in progress")
            return
        }
        if (self.operations.isEmpty) {
            return
        }
        
        current = self.operations[0]
        if (current != nil) {
            current?.perform(self.peripheral!)
        }
    }
}


class DeviceOperation {
    
    var characteristic: CBCharacteristic? = nil
    
    init(characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
    
    func perform(peripheral: CBPeripheral) {}
}

class DeviceReadOperation: DeviceOperation {
    override func perform(peripheral: CBPeripheral) {
        peripheral.readValueForCharacteristic(self.characteristic!)
    }
}

class DeviceWriteOperation: DeviceOperation {
    var data: NSData? = nil
    
    init(characteristic: CBCharacteristic, data: NSData) {
       // self.characteristic = characteristic
        self.data = data
        super.init(characteristic: characteristic)
    }
    
    override func perform(peripheral: CBPeripheral) {
        peripheral.writeValue(self.data!, forCharacteristic: self.characteristic!, type: CBCharacteristicWriteType.WithResponse)
    }
}

class DeviceEnableNotificationOperation: DeviceOperation {
    override func perform(peripheral: CBPeripheral) {
        peripheral.setNotifyValue(true, forCharacteristic: self.characteristic!)
    }
}