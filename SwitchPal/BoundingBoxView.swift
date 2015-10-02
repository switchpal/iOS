//
//  BoundingBoxView.swift
//  SwitchPal
//
//  Created by Chunliang Lyu on 20/5/15.
//  Copyright (c) 2015 SwitchPal. All rights reserved.
//


import UIKit

// draw a bounding box based on a list of points, used in QR Code scanner
class BoundingBoxView: UIView {
    
    var outline: CAShapeLayer!
    var corners: Array<CGPoint>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        outline = CAShapeLayer()
        outline.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.8).CGColor
        outline.lineWidth = 2.0
        outline.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(outline)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setCorners(corners: Array<CGPoint>) {
        if (self.corners == nil || self.corners != corners) {
            self.corners = corners
            self.outline.path = createPathFromPoints(corners).CGPath
        }
    }
    
    func createPathFromPoints(points: Array<CGPoint>) -> UIBezierPath {
        let path = UIBezierPath()
        // Start at the first corner
        path.moveToPoint(points.first!)
        
        // Now draw lines around the corners
        for i in 1..<points.count {
            path.addLineToPoint(points[i])
        }
        
        // And join it back to the first corner
        path.addLineToPoint(points.first!)
        
        return path;
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
    // Drawing code
    }
    */
    
}
