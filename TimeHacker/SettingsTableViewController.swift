//
//  SettingsTableViewController.swift
//  TimeHacker
//
//  Created by artwalk on 10/13/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var navDoneBtn: UIBarButtonItem!
    
    @IBAction func navDoneBtnAction(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}