//
//  QRCodeViewController.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//

import UIKit
import AVFoundation


// cannot test without real device
// refer to: http://www.shinobicontrols.com/blog/posts/2013/10/11/ios7-day-by-day-day-16-decoding-qr-codes-with-avfoundation
class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var boundingBox: BoundingBoxView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let avCaptureSession = AVCaptureSession()
        let avCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?;
        if let avCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(avCaptureDevice, error: &error) as? AVCaptureDeviceInput {
            avCaptureSession.addInput(avCaptureDeviceInput)
        } else {
            println("cannot get input")
            println(error)
            return
        }
        
        // setup the preview layer
        let previewLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(avCaptureSession) as! AVCaptureVideoPreviewLayer
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.bounds = self.view.bounds
        previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        self.view.layer.addSublayer(previewLayer)
        
        // run
        avCaptureSession.startRunning()
        
        // ==== QRCode detector ====
        let output = AVCaptureMetadataOutput()
        avCaptureSession.addOutput(output)
        println(output.availableMetadataObjectTypes)
        // we are only interested in QR Code
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        
        // ==== Bounding box ====
        boundingBox = BoundingBoxView(frame: self.view.bounds)
        boundingBox.backgroundColor = UIColor.clearColor()
        boundingBox.hidden = true
        self.view.addSubview(boundingBox)
    }
    
    // called when we got a valid QRCode
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for metadataObject in metadataObjects {
            if metadataObject.type == AVMetadataObjectTypeQRCode {
                let transformed = metadataObject as! AVMetadataMachineReadableCodeObject
                
                println(transformed.stringValue)
                // check if it contains a valid device info
                if let device = Device.initFromUrl(transformed.stringValue) {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    device.writeDefaults(defaults)
                }
                self.performSegueWithIdentifier("scanToDeviceSegue", sender: self)
                
                // ==== bounding box ====
                boundingBox.frame = transformed.bounds
                //println("bounding box frame: \(boundingBox.frame)")
                boundingBox.hidden = false
                //println(transformed.corners)
                let translatedCorners = translatePoints(transformed.corners, fromView: self.view, toView: boundingBox)
                //println(translatedCorners)
                boundingBox.setCorners(translatedCorners)
            }
        }
    }
    
    func translatePoints(points: Array<AnyObject>, fromView: UIView, toView: UIView) -> Array<CGPoint> {
        var translatedPoints = Array<CGPoint>()
        for p: AnyObject in points {
            let point = p as! [String: AnyObject]
            let pointX = point["X"]! as! CGFloat
            let pointY = point["Y"]! as! CGFloat
            let pp = CGPointMake(pointX, pointY)
            translatedPoints.append(fromView.convertPoint(pp, toView: toView))
        }
        return translatedPoints
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
