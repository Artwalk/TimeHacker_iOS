//
//  ICALReminders.m
//  iCaleminder
//
//  Created by artwalk on 6/20/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "ICALReminders.h"

@interface ICALReminders ()

@property (nonatomic, strong) EKEventStore *reminderStore;

@end

@implementation ICALReminders


+ (ICALReminders *)getInstance {
    static ICALReminders *iCalRemindersInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iCalRemindersInstance = [[self alloc] initPrivate];
    });
    
    return iCalRemindersInstance;
}

- (instancetype)initPrivate {
    self = [super init];
    
    if (self) {
        [self getAuthority];
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [ICALReminders]" userInfo:nil];
    
    return nil;
}

- (void)getAuthority {
    
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted,
                                                                    NSError *error) {
        _reminderStore =  store;
    }];
}

- (NSArray *)getIncompleteReminders {
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:5];
    
    NSPredicate *predicate = [_reminderStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:nil];
    [_reminderStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        
        for (EKReminder *reminder in reminders) {
            NSString *title = [NSString stringWithFormat:@"%@", reminder.title];
            NSLog(@"%@", title);
            [result addObject:title];
        }
    }];
    
    return result;
}

@end
