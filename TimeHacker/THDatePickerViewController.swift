//
//  THDatePickerViewController.swift
//  TimeHacker
//
//  Created by Artwalk on 1/4/15.
//  Copyright (c) 2015 artwalk. All rights reserved.
//

import UIKit

class THDatePickerViewController: UIViewController {

    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AnalysisIdentifier" {
            let result = THCalenderAnalysis().AnalysisResultList(startDatePicker.date, endDate: endDatePicker.date)
            
            var array = [String]()
            for (k,v ) in result {
                array.append("\(k) : " + "\(v/3600)h")
            }
            let vc = segue.destinationViewController as THAnalysisResultTVC
            
            vc.resultArray = array
        }
        
    }
    

}
