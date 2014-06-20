//
//  ICALPomo.m
//  iCaleminder_iOS
//
//  Created by artwalk on 6/10/14.
//  Copyright (c) 2014 artwalk. All rights reserved.
//

#import "ICALPomoStore.h"

@interface ICALPomoStore ()

@end

@implementation ICALPomoStore

+ (ICALPomoStore *)getInstance {
    static ICALPomoStore *iCalPomoStoreInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iCalPomoStoreInstance = [[self alloc] initPrivate];
    });

    return iCalPomoStoreInstance;
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
