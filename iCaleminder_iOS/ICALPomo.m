//
//  ICALPomo.m
//  iCaleminder_iOS
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "ICALPomo.h"


@interface ICALPomo ()

@property EKEventStore* eventStore;

@end

@implementation ICALPomo

+ (ICALPomo *)getInstance {
    static ICALPomo *iCalPomoInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iCalPomoInstance = [[self alloc] initPrivate];
    });

    return iCalPomoInstance;
}

- (instancetype)initPrivate {
    self = [super init];
    
    [self getAuthority];
    
    if (self) {
        _state = EnumStop;
        _interval = 25;
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [ICALPomo]" userInfo:nil];
    
    return nil;
}

- (BOOL)insertToiCal {
    
    return [self writeEvent2iCal]?YES:NO;
}

- (void)getAuthority {
    
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,
                                                                    NSError *error) {
        _eventStore =  store;
        
    }];

}

- (BOOL) writeEvent2iCal {
    
    if (_pomoTitle == nil || _pomoStartTime == nil || _pomoEndTime == nil) {
        return NO;
    }
    
    if (_pomoEndTime < _pomoStartTime) {
        return NO;
    }
    
    EKEvent *event = [EKEvent eventWithEventStore:_eventStore];
    
    event.title = _pomoTitle;
    event.endDate = _pomoEndTime;
    event.startDate = _pomoStartTime;
    
    [event setCalendar:[_eventStore defaultCalendarForNewEvents]];
    NSError *err;
    NSString *ical_event_id;
    //save your event
    if([_eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err]){
        ical_event_id = event.eventIdentifier;
        NSLog(@"%@",ical_event_id);
        NSLog(@"\ntitle: %@\nstart: %@\nend: %@", _pomoTitle, _pomoStartTime, _pomoEndTime);
    }

    return err==nil?YES:NO;
}



@end
