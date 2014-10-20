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
    
    override func viewDidLoad() {
//        println(DeviceInfo().info())
    }
    
    @IBAction func feedbackTextFieldEditingChanged(sender: UITextField) {
        self.submitBarButtonItem?.enabled = (self.feedbackTextField?.text != "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func submitBarButtonItemAction(sender: UIBarButtonItem) {
        let url = NSURL(string:serverUrl)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: 3.0)
        request.HTTPMethod = "POST"
        
        let jsonObject = ["data":DeviceInfo().info()]
        
        if NSJSONSerialization.isValidJSONObject(jsonObject) {
            if let data = NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions.PrettyPrinted, error: nil) {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                request.HTTPBody = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
//            println(error)
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        
        
    }
}