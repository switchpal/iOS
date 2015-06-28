//
//  ConfigViewController.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var temperatureRangeMinSlider: UISlider!
    @IBOutlet weak var temperatureRangeMaxSlider: UISlider!
    @IBOutlet weak var temperatureRangeMinLabel: UILabel!
    @IBOutlet weak var temperatureRangeMaxLabel: UILabel!
    
    var min: Float = 24
    var max: Float = 28
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.temperatureRangeMinSlider.setValue((min-MIN) / (MAX-MIN), animated: false)
        self.temperatureRangeMaxSlider.setValue((max-MIN) / (MAX-MIN), animated: false)
        self.updateFromSliders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    let MIN:Float = 20
    let MAX:Float = 32
    
    func updateFromSliders() {
        self.min = MIN  + temperatureRangeMinSlider.value * (MAX-MIN)
        self.max = MIN  + temperatureRangeMaxSlider.value * (MAX-MIN)
        self.temperatureRangeMinLabel.text = NSString(format: "(%.1f°C)", min) as String
        self.temperatureRangeMaxLabel.text = NSString(format: "(%.1f°C)", max) as String
    }
    
    @IBAction func onTemperatureRangeMinChanged(sender: AnyObject) {
        updateFromSliders()
    }

    @IBAction func onTemperatureRangeMaxChanged(sender: AnyObject) {
        updateFromSliders()
    }

    @IBAction func onCancelTouchUpInside(sender: AnyObject) {
        performSegueWithIdentifier("configToDeviceSegue", sender: self)
    }
    
    @IBAction func onSaveTouchUpInside(sender: AnyObject) {
        println("min: \(min), max: \(max)")
        
        if (min < 20 || min > 32 || max < 20 || max > 32) {
            let alert = UIAlertView(title: "Error", message: "Temperature should between 20 to 32, and max should be larger than min", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let device = Device.initFromDefaults(defaults) {
            device.temperatureRangeMin = min
            device.temperatureRangeMax = max
            device.writeDefaults(defaults)
            
            performSegueWithIdentifier("configToDeviceSegue", sender: self)
        }
        //println("min: ", temperatureRangeMin!.text!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
        if segue.identifier == "configToDeviceSegue" {
            println("prepare configToDeviceSegure")
            let ctl = segue.destinationViewController as! DeviceViewController
            ctl.fromView = "config"
        }
    }
}
