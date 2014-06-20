//
//  ICALReminders.h
//  iCaleminder
//
//  Created by artwalk on 6/20/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface ICALReminders : NSObject


+ (ICALReminders *)getInstance;

- (NSArray *)getIncompleteReminders;
//- (void)getAuthority;

@end
