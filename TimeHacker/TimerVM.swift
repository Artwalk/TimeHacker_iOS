//
//  TimerVM.swift
//  TimeHacker
//
//  Created by Artwalk on 6/7/15.
//  Copyright (c) 2015 artwalk. All rights reserved.
//

import Foundation
import EventKit

class TimerViewModel {
    
    let taskDict = Dictionary<String, AnyObject>()
    
    var title:String?
    var startDate:NSDate?
    var endDate:NSDate?
    
    func saveToCal() {
        
        let store = EKEventStore()
        
        store.requestAccessToEntityType(EKEntityTypeEvent) {(granted, error) in
            if !granted { return }
            
            var event = EKEvent(eventStore: store)
            event.title = self.title
            event.startDate = self.startDate
            event.endDate = self.endDate
            
            event.calendar = store.defaultCalendarForNewEvents
            var err: NSError?
            store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
            
//            self.savedEventId = event.eventIdentifier //save event id to access this particular event later
        }
    }
    
}