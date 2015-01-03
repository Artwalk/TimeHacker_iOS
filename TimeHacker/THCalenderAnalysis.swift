
//
//  ICALCalenderAnalysis.swift
//  TimeHacker
//
//  Created by Artwalk on 1/3/15.
//  Copyright (c) 2015 artwalk. All rights reserved.
//

import UIKit
import EventKit

class THCalenderAnalysis: NSObject {
    
//    var startDate:NSDate
//    var endDate:NSDate
    
    private let eventStore = EKEventStore()
    
    
    func AnalysisResultList(startDate:NSDate, endDate:NSDate) -> Dictionary<String, Double> {
         var dict = Dictionary<String, Double>()
        let calenders = predicteCalenders()
        
//        eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { (granted, error) -> Void in
//            if granted {
                let predicte = self.eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: calenders)
                if let events = self.eventStore.eventsMatchingPredicate(predicte) {
                   
                    for event in events {
                        let e = event as EKEvent
                        var sum:Double = 0
                        if let s =  dict[e.calendar.title] {
                            sum = s + Double(e.endDate.timeIntervalSinceDate(e.startDate))
                        }
                        dict[e.calendar.title] = sum
                    }
                }
        
        return dict
//            }
//         })
    }
    
    func predicteCalenders() -> [EKCalendar] {
        var calenders:[EKCalendar] = []
        if let cals = eventStore.calendarsForEntityType(EKEntityTypeEvent) as? [EKCalendar] {
            for cal in cals {
                if cal.type.value == EKCalendarTypeCalDAV.value {
                    calenders.append(cal)
                }
            }
        }
        
        return calenders
    }
    
    func predicteAllEvents() {
        
    }
    
}
