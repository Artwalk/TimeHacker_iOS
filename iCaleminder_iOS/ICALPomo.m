//
//  ICALPomo.m
//  iCaleminder_iOS
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "ICALPomo.h"

@interface ICALPomo ()

@end

@implementation ICALPomo

+ (ICALPomo *)getInstance {
    static ICALPomo *icalPomoInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icalPomoInstance = [[self alloc] initPrivate];
    });

    return icalPomoInstance;
}

- (instancetype)initPrivate {
    self = [super init];
    
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


@end
