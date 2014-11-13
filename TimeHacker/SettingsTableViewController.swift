//
//  SettingsTableViewController.swift
//  TimeHacker
//
//  Created by artwalk on 10/13/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit
import EventKit

class SettingsTableViewController: UITableViewController {
    
    let syncCalKey = "syncCalKey"
    let maidenSyncCalKey = "maidenSyncCalKey"
    
    @IBOutlet weak var navDoneBtn: UIBarButtonItem!
    @IBOutlet weak var syncCalSwitch: UISwitch!
    
    @IBAction func navDoneBtnAction(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func syncCalSwitchValueChanged(sender: UISwitch) {
        let on = sender.on
        
        if sender.on {
            getEventAuthority()
            setBool(true, forKey: syncCalKey)
        } else {
            setBool(false, forKey: syncCalKey)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if boolForKey(maidenSyncCalKey) || !boolForKey(syncCalKey) {
            syncCalSwitch.on = false
        } else {
            getMaidenEventAuthority()
        }
    }
    
    func getMaidenEventAuthority() {
        let store = EKEventStore()
        store.requestAccessToEntityType(EKEntityTypeEvent, completion: { (greanted, err) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.syncCalSwitch.on = greanted
            })
        })
    }
    
    
    func getEventAuthority() {
        let store = EKEventStore()
        store.requestAccessToEntityType(EKEntityTypeEvent, completion: { (greanted, err) -> Void in
            self.setBool(false, forKey: self.maidenSyncCalKey)
            
            if !greanted {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                    UIAlertView(title: "Please enable the Access", message: "Settings->Timehacker->Calendars", delegate: self, cancelButtonTitle: "OK").show()
                    self.syncCalSwitch.on = false
                })
            }
        })
    }
    
    func setBool(value:Bool, forKey:String) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: forKey)
    }
    
    func boolForKey(key:String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(key)
    }
}