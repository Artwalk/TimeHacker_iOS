//
//  THPomo.m
//  TimeHacker
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "THPomo.h"
#import "Pomo.h"

@interface THPomo ()

@property (nonatomic, strong) NSManagedObject *managedObject;

@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, readonly ,strong) NSString *pomoEntityName;

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
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [THPomo]" userInfo:nil];
    
    return nil;
}

# pragma mark - iCal

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
    if (_title == nil || self.startTime == nil) {
        return NO;
    }
    
    EKEvent *event = [EKEvent eventWithEventStore:_eventStore];
    
    event.title = _title;
    event.startDate = self.startTime;
    event.endDate = _endDate = [NSDate dateWithTimeInterval:self.interval*60 sinceDate:self.startTime];
    
    [event setCalendar:[_eventStore defaultCalendarForNewEvents]];
    NSError *err;
    NSString *ical_event_id;
    //save your event
    if([_eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err]){
        ical_event_id = event.eventIdentifier;
    }
    
    return err==nil?YES:NO;
}

- (void)creatingCalendarIniCloud {
    
}

#pragma mark - setter

- (void)setStartTime:(NSDate *)startTime {
    if (_managedObject != nil) {
        [self.managedObject setValue:startTime forKey:@"startTime"];
    }
}

- (void)setInterval:(NSInteger)interval {
    if (_managedObject != nil) {
        [self.managedObject setValue:[NSNumber numberWithInteger:interval] forKey:@"interval"];
    }
}

#pragma mark - getter

- (NSString *)pomoEntityName {
    return @"Pomo";
}

- (NSDate *)startTime {
    return [self.managedObject valueForKey:@"startTime"];
}

- (NSInteger)interval {
    return [[self.managedObject valueForKey:@"interval"] intValue];
}

- (NSManagedObject *)managedObject {
    if (_managedObject != nil) {
        return _managedObject;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.pomoEntityName];
    NSError *err = nil;
    NSArray *pomoItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&err];
    if ([pomoItems count] == 0) {
        _managedObject = [self createNewObject];
    } else {
        _managedObject = pomoItems[0];
    }
    
    return _managedObject;
}

- (NSManagedObject *)createNewObject {
    
    Pomo *newPomo = [NSEntityDescription
                     insertNewObjectForEntityForName:self.pomoEntityName
                     inManagedObjectContext:self.managedObjectContext];
    if (newPomo != nil){
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]) {
            NSLog(@"Successfully saved the context.");
        } else {
            NSLog(@"Failed to save the context. Error = %@", savingError);
        }
    } else {
        NSLog(@"Failed to create the new person.");
    }
    
    return newPomo;
}


@end
