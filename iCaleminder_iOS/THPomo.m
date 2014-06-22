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
@property (nonatomic, strong) EKSource *icloudEventSource;

@property (nonatomic, strong) EKCalendar *timeHackerCalendar;

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


- (EKSource *)icloudEventSource {
    for (EKSource *source in self.eventStore.sources){
        if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
            _icloudEventSource = source;
            break;
        }
    }
    
    return _icloudEventSource;
}

- (EKCalendar *)timeHackerCalendar {
    NSSet *calendars = [self.icloudEventSource calendarsForEntityType:EKEntityTypeEvent];
    for (EKCalendar *calendar in calendars){
        if ([calendar.title isEqualToString:@"TimeHarker"]) {
            _timeHackerCalendar = calendar;
        }
    }
    
    if (_timeHackerCalendar == nil) {
        // not found & create
        EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
        calendar.title = @"TimeHarker";
        calendar.source = self.icloudEventSource;
        
        NSError *error = nil;
        if ([_eventStore saveCalendar:calendar commit:YES error:&error]) {
            _timeHackerCalendar = calendar;
        }
    }
    
    return _timeHackerCalendar;
}

- (BOOL)writeEvent2iCal {
    if (_title == nil || self.startDate == nil) {
        return NO;
    }
    
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    
    event.title = _title;
    event.startDate = self.startDate;
    event.endDate = _endDate = [NSDate dateWithTimeInterval:self.interval*60 sinceDate:self.startDate];
    
    event.calendar = self.timeHackerCalendar;
    
    NSError *err;
    if([self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err]){
//        NSLog(@"event.eventIdentifier: %@", event.eventIdentifier);
    }
    
    return err==nil?YES:NO;
}

#pragma mark - setter

- (void)setStartDate:(NSDate *)startDate {
    if (_managedObject != nil) {
        [self.managedObject setValue:startDate forKey:@"startDate"];
    }
}

- (void)setInterval:(NSInteger)interval {
    if (_managedObject != nil) {
        [self.managedObject setValue:[NSNumber numberWithInteger:interval] forKey:@"interval"];
    }
}

#pragma mark - getter

- (EKEventStore *)eventStore {
    if (_eventStore == nil) {
        [self getAuthority];
    }
    
    return _eventStore;
}

- (NSString *)pomoEntityName {
    return @"Pomo";
}

- (NSDate *)startDate {
    return [self.managedObject valueForKey:@"startDate"];
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
//            NSLog(@"Successfully saved the context.");
        } else {
            NSLog(@"Failed to save the context. Error = %@", savingError);
        }
    } else {
//        NSLog(@"Failed to create the new Pomo.");
    }
    
    return newPomo;
}


@end
