//
//  ViewController.swift
//  TimeHacker
//
//  Created by Artwalk on 6/7/15.
//  Copyright (c) 2015 artwalk. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    let timerVM = TimerViewModel()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    
    var counting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableStartBtn(false)
    }
    
    @IBAction func tittleTextFieldEditingChanged(sender: UITextField) {
        
        if !sender.text.isEmpty  {
            enableStartBtn(true)
        } else {
            enableStartBtn(false)
        }
        
    }
    
    
    @IBAction func startBtnTouched(sender: UIButton) {
        if counting {
            stopCounting()
        } else {
            startCounting()
        }
        
        counting = !counting
    }
    
    func startCounting() {
        timerVM.title = titleTextField.text
        timerVM.startDate = NSDate()
        
        countingStartBtn(true)
    }
    
    func stopCounting() {
        timerVM.endDate = NSDate()
        timerVM.saveToCal()
        
        countingStartBtn(false)
    }
    
    
    func enableStartBtn(enable:Bool) {
        startBtn.enabled = enable
        countingStartBtn(!enable)
       
    }
    
    func countingStartBtn(counting:Bool) {
        if counting {
            startBtn.backgroundColor = UIColor.lightGrayColor()
            startBtn.setTitle("Stop", forState: .Normal)
        } else {
            startBtn.backgroundColor = UIColor(rgba: "#4460FF")
            startBtn.setTitle("Start", forState: .Normal)
        }
    }
}

