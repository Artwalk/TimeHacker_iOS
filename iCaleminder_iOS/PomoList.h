//
//  ICALPomoItem.h
//  TimeHacker
//
//  Created by artwalk on 6/22/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PomoList : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * title;

@end
