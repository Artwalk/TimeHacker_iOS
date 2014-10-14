//
//  FeedbackViewController.swift
//  TimeHacker
//
//  Created by artwalk on 10/13/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextFieldDelegate {
    
    //  let serverUrl = "http://timehacker.ahorn.me/feedback";
    let serverUrl = "http://127.0.0.1:8001/feedback";
    
    @IBOutlet weak var feedbackTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitBarButtonItem: UIBarButtonItem!
    
    var deviceInfo:NSDictionary?
    
    @IBAction func feedbackTextFieldEditingChanged(sender: UITextField) {
        self.submitBarButtonItem?.enabled = (self.feedbackTextField?.text != "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}