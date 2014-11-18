//
//  ARTCircularSlider.swift
//  ARTCircularSlider
//
//  Created by Artwalk on 10/30/14.
//  Copyright (c) 2014 Artwalk. All rights reserved.
//

import UIKit

protocol ARTCircularSliderViewDelegate {
    func circulValueChanged(circularSliderView:ARTCircularSliderView)
}

@IBDesignable
class ARTCircularSliderView : UIControl {
    
    var delegate:ARTCircularSliderViewDelegate!
    
    var lineWidth = CGFloat(13)
    let unfilledColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    let filledColor = UIColor.blueColor()

    var centerPoint:CGPoint!
    var halfHeight:CGFloat!
    var halfWidth:CGFloat!
    var radius:CGFloat!
    
    let maximumValue:CGFloat = 60.0*60.0
    let minimumValue:CGFloat = 0.0
    
    var angle:CGFloat = 0
    var curValue:CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configView()
    }
    
    // Drawing
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        radius = halfWidth - lineWidth/2
        
        var ctx = UIGraphicsGetCurrentContext()
        CGContextAddArc(ctx, halfWidth, halfHeight, radius, 0, CGFloat(M_PI*2), 0)
        drawCircle(ctx, color: unfilledColor)
        
        CGContextAddArc(ctx, halfWidth, halfHeight, radius, CGFloat(M_PI*3/2), CGFloat(3*M_PI/2)-toRad(angle), 0)
        drawCircle(ctx, color: filledColor)
    }
    
    func configView () {
        let size = frame.size
        halfHeight = size.height/2
        halfWidth = size.width/2
        centerPoint = CGPointMake(halfWidth, halfHeight)
        backgroundColor = UIColor.clearColor()
    }
    
    func drawCircle (ctx:CGContextRef, color:UIColor  ) {
        color.setStroke()
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetLineCap(ctx, kCGLineCapButt)
        CGContextDrawPath(ctx, kCGPathStroke)
    }
    
    // UIControl
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        let lastPoint = touch.locationInView(self)
        moveHandle(lastPoint)
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        delegate?.circulValueChanged(self)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
    }
    
    func setCurValue(value:Double) {
        curValue = CGFloat(value)
        angleFromValue()
        self.setNeedsDisplay()
    }
    
    func moveHandle(point:CGPoint) {
        var curAngle = floor(angleFromNorth(centerPoint, p2: point, angle: false))
        angle = CGFloat(360-90) - curAngle
        curValue = valueFromAngle()
        self.setNeedsDisplay()
    }
    
    // helper
    func angleFromNorth(p1:CGPoint, p2:CGPoint ,angle:Bool) -> CGFloat {
        var p = CGPointMake(p2.x-p1.x, p2.y-p1.y)
        let vmag = sqrt(p.x*p.x + p.y*p.y)
        p.x /= vmag
        p.y /= vmag
        let radians = atan2(p.y, p.x)
        let result = toDeg(radians)
        
        return result >= 0 ? result : result+360
    }
    
    func valueFromAngle() -> CGFloat {
        curValue =  angle < 0 ? -angle : (270 + 90 - angle)
        
        return (curValue * (maximumValue - minimumValue))/CGFloat(360)
    }
    
    func angleFromValue() -> CGFloat {
        angle =  curValue * CGFloat(360)/(maximumValue - minimumValue)
        angle = angle>180 ?  -angle : 360 - angle
    
        return angle
    }
    
    func toDeg(v:CGFloat) -> CGFloat {
        return CGFloat(180.0) * v / CGFloat(M_PI)
    }
    
    func toRad (v:CGFloat) -> CGFloat {
        return CGFloat(M_PI) * v / CGFloat(180)
    }
}
