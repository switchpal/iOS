//
//  ViewController.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 5/20/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    

    @IBOutlet weak var scanButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func scan(sender: UIButton) {
        print("lets scan")
        
        self.performSegueWithIdentifier("scanSegue", sender: self)
        //self.performSegueWithIdentifier("mainToDeviceSegue", sender: self)
    }
}

