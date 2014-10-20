//
//  DeviceInfo.swift
//  TimeHacker
//
//  Created by Artwalk on 10/20/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

import UIKit

class DeviceInfo {
    
    let device = UIDevice.currentDevice()
    let processInfo = NSProcessInfo.processInfo()
    
    func info() -> Dictionary<String, String> {
        let info = [
            "name" : device.name,
            "sysName" : device.systemName,
            "sysVersion" : device.systemVersion,
            "model" : device.model,
            "localizedModel" : device.localizedModel,
            "batteryLevel" : "\(device.batteryLevel)",
            
            "hostName" : processInfo.hostName,
            "operatingSystemName" : processInfo.operatingSystemName(),
            "operatingSystemVersionString" : processInfo.operatingSystemVersionString,
            "physicalMem" : "\(processInfo.physicalMemory)",
            "processName" : processInfo.processName
        ]
        
        return info
    }
    
}