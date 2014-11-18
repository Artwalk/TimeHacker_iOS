//
//  THCircularSliderViewController.swift
//  TimeHacker
//
//  Created by Artwalk on 11/13/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit
import EventKitUI

class THCircularSliderViewController: UIViewController, ARTCircularSliderViewDelegate, EKCalendarChooserDelegate {
    
    var defaultPomoTime = 25*60.0
    var curPomoTime = 25*60.0
    
    var startDate:NSDate!
    var timer:NSTimer!
    
    enum btnStatues {
        case start
        case stop
        case breakTime
    }
    var startBtnSatues = btnStatues.stop
    
    override func viewDidLoad() {
        timer = NSTimer()
        circularSlider.delegate = self
        
        outsideCircularSliderView.lineWidth = 2
        outsideCircularSliderView.enabled = false
        
        updateView()
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var circularSlider: ARTCircularSliderView!
    @IBOutlet weak var outsideCircularSliderView: ARTCircularSliderView!
    
    func circulValueChanged(circularSliderView: ARTCircularSliderView) {
        defaultPomoTime = Double(circularSliderView.curValue)
        curPomoTime = defaultPomoTime
        timeLabel.text = formatTime(curPomoTime)
    }
    
    @IBAction func giveUpBarButtonItemAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func formatTime(secondes:Double) -> String {
//        return String(format: "%02.0f:%02.0f", floor(secondes/60), secondes%60)
        let s = Int(secondes)
        return String(format: "%02d:%02d", s/60, s%60)
    }

    
    @IBAction func startBtn(sender: UIButton) {
        switch startBtnSatues {
        case .start:
            var ac = UIAlertController(title: "", message:  "Stop Pomodoro?", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.willStopCounting()
            })
            ac.addAction(cancelAction)
            ac.addAction(okAction)
            
            self.presentViewController(ac, animated: true, completion: nil)
        case .stop:
            willStartCounting()
        case .breakTime:
            
            startBtnSatues = .stop
        }
    }
    
    func willStartCounting() {
        circularSlider.enabled = false
        startDate = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "startCounting", userInfo: nil, repeats: true)
        timeLabel.textColor = UIColor.redColor()
        startBtnSatues = .start
    }
    
    func willStopCounting() {
        timeLabel.textColor = UIColor.blueColor()
        startBtnSatues = .stop
        timer.invalidate()
        
        curPomoTime = defaultPomoTime
        updateView()
        circularSlider.enabled = true
    }
    
    func startCounting() {
        curPomoTime = defaultPomoTime - Double(NSDate().timeIntervalSinceDate(startDate))
        if curPomoTime < 0 {
            willStopCounting()
            pomoDone()
        }
        updateView()
    }
    
    func pomoDone() {
        var cc = EKCalendarChooser(selectionStyle: EKCalendarChooserSelectionStyleSingle, displayStyle: EKCalendarChooserDisplayWritableCalendarsOnly, entityType: EKEntityTypeEvent, eventStore:
            THPomo.getInstance().eventStore)
        cc.delegate = self
        cc.showsDoneButton = true
        cc.showsCancelButton = true
        
        self.navigationController?.pushViewController(cc, animated: true)
//        self.presentViewController(cc, animated: true, completion: nil)
    }
    
    func calendarChooserDidFinish(calendarChooser: EKCalendarChooser!) {
        
    }
    
    func calendarChooserDidCancel(calendarChooser: EKCalendarChooser!) {
        
    }
    
    func updateView() {
        circularSlider.setCurValue(curPomoTime)
        timeLabel.text = formatTime(curPomoTime)
    }

}
