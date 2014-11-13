//
//  THCircularSliderViewController.swift
//  TimeHacker
//
//  Created by Artwalk on 11/13/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit

class THCircularSliderViewController: UIViewController, ARTCircularSliderViewDelegate {
    
    override func viewDidLoad() {
        circularSlider.delegate = self
        
        outsideCircularSliderView._lineWidth = 2
        outsideCircularSliderView.enabled = false
        outsideCircularSliderView._curValue = 60.0
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var circularSlider: ARTCircularSliderView!
    @IBOutlet weak var outsideCircularSliderView: ARTCircularSliderView!
    
    func circulValueChanged(circularSliderView: ARTCircularSliderView) {
//println(        circularSliderView._curValue)
        timeLabel.text = String(format: "%2d:00", Int(floor(circularSlider._curValue)))
    }

}
