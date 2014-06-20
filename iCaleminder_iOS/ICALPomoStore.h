//
//  ICALPomo.h
//  iCaleminder_iOS
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICALPomoStore : NSObject

@property (nonatomic) NSDate *pomoStartTime;
@property (nonatomic) NSDate *pomoEndTime;
@property (nonatomic) NSDate *breakStartTime;

@property (nonatomic) NSString *eventTitle;
// maybe add eventType later

@property (nonatomic) NSInteger interval;

@property (nonatomic) NSInteger state;

typedef NS_OPTIONS(NSUInteger, EnumState)
{
    EnumStop    = 0,          // 0
    EnumBreak   = 1,     // 1
    EnumStart      = 1 << 1     // 2
};


+ (ICALPomoStore *)getInstance;


@end
