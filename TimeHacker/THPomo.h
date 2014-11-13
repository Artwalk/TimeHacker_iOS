//
//  THPomo.h
//  TimeHacker
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <CoreData/CoreData.h>

@interface THPomo : NSObject <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSDate *breakDate;

@property (nonatomic, strong) EKEventStore* eventStore;

@property (nonatomic) NSString *title;
// maybe add eventType later

@property (nonatomic) NSInteger interval;
@property (nonatomic) NSInteger state;

@property (nonatomic, strong) EKCalendar *calendar;

//@property (nonatomic, strong) UINavigationController *navigationController;

typedef NS_OPTIONS(NSUInteger, EnumState)
{
    EnumStop    = 0,          // 0
    EnumBreak   = 1,     // 1
    EnumStart      = 1 << 1     // 2
};


+ (THPomo *)getInstance;

- (BOOL)insertToiCal;

@end
