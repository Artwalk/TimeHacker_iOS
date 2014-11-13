//
//  FeedbackViewController.swift
//  TimeHacker
//
//  Created by artwalk on 10/13/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextFieldDelegate {
    
//    let serverUrl = "http://timehacker.ahorn.me/feedback"
    let serverUrl = "http://127.0.0.1:8001/feedback"
    
    @IBOutlet weak var feedbackTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func feedbackTextFieldEditingChanged(sender: UITextField) {
        self.submitBarButtonItem?.enabled = (self.feedbackTextField?.text != "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func submitBarButtonItemAction(sender: UIBarButtonItem) {
        (submitBarButtonItem.enabled, emailTextField.enabled, feedbackTextField.enabled) = (false,false,false)
        
        let url = NSURL(string:serverUrl)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 3.0)
        request.HTTPMethod = "POST"
        
        let userInfoOjb = ["feedback":feedbackTextField.text, "email":emailTextField.text]
        let jsonObject:Dictionary<String, AnyObject>! = ["userInfo":userInfoOjb ,"deviceInfo":DeviceInfo().info()]
        
        if NSJSONSerialization.isValidJSONObject(jsonObject) {
            if let data = NSJSONSerialization.dataWithJSONObject(jsonObject, options:nil, error: nil) {
                
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                request.HTTPBody = ("data=" + string!).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            var msg:String!
            if error != nil {
                println(error)
                msg = "Sorry, Submit failed!"
                self.submitBarButtonItem.enabled = true
            } else {
                msg = "Your feedback has been submitted."
                (self.emailTextField.text, self.feedbackTextField.text) = ("" ,"")
                self.submitBarButtonItem.enabled = false
            }
            
            (self.emailTextField.enabled, self.feedbackTextField.enabled) = (true,true)
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
}