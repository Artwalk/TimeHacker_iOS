//
//  THPomo.m
//  TimeHacker
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "THPomo.h"

@interface THPomo ()

@property EKEventStore* eventStore;

@end

@implementation THPomo

+ (THPomo *)getInstance {
    static THPomo *THPomoInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        THPomoInstance = [[self alloc] initPrivate];
    });

    return THPomoInstance;
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
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [THPomo]" userInfo:nil];
    
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
