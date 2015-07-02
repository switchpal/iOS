//
//  Analytics.swift
//  CoolerPal
//
//  Created by Chunliang Lyu on 2/7/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import Foundation
import Parse

class Analytics {
    static let EVENT_APP = "App"
    static let EVENT_DEVICE = "Device"
    
    class func getControlModeString(mode: Bool!) -> String {
        var modeStr: String
        if (mode != nil && mode == true) {
            modeStr = "auto"
        } else {
            modeStr = "manual"
        }
        return modeStr
    }
    
    class func trackSetControlMode(mode: Bool!) {
        let dimensions = [
            "setControlMode" : getControlModeString(mode),
        ]
        PFAnalytics.trackEvent(EVENT_APP, dimensions: dimensions)
    }
    
    class func trackControlMode(mode: Bool!) {
        let dimensions = [
            "ControlMode" : getControlModeString(mode),
        ]
        PFAnalytics.trackEvent(EVENT_DEVICE, dimensions: dimensions)
    }
    
    class func getSwitchStateString(state: Bool!) -> String {
        var stateStr: String
        if (state != nil && state == true) {
            stateStr = "on"
        } else {
            stateStr = "off"
        }
        
        return stateStr
    }
    
    class func trackSetSwitchState(state: Bool!) {
        let dimensions = [
            "setSwitchState" : getSwitchStateString(state),
        ]
        PFAnalytics.trackEvent(EVENT_APP, dimensions: dimensions)
    }
    
    class func trackSwitchState(state: Bool!) {
        let dimensions = [
            "SwitchState" : getSwitchStateString(state)
        ]
        PFAnalytics.trackEvent(EVENT_DEVICE, dimensions: dimensions)
    }
    
    class func trackSetTemperatureRange(min: Float, max: Float) {
        let dimensions = [
            "setTemperatureRangeMin": NSString(format: "%.2f", min) as String,
            "setTemperatureRangeMax": NSString(format: "%.2f", max) as String,
        ]
        PFAnalytics.trackEvent(EVENT_APP, dimensions: dimensions)
    }
    
    class func trackTemperatureRange(min: Float, max: Float) {
        let dimensions = [
            "TemperatureRangeMin": NSString(format: "%.2f", min) as String,
            "TemperatureRangeMax": NSString(format: "%.2f", max) as String,
        ]
        PFAnalytics.trackEvent(EVENT_DEVICE, dimensions: dimensions)
    }
    
    class func trackTemperature(temperature: Float) {
        let dimensions = [
            "Temperature": NSString(format: "%.2f", temperature) as String,
        ]
        PFAnalytics.trackEvent(EVENT_DEVICE, dimensions: dimensions)
    }
    
    class func trackClick(element: String) {
        let dimentions = [
            "Click": element
        ]
        PFAnalytics.trackEvent(EVENT_APP, dimensions: dimentions)
    }
}