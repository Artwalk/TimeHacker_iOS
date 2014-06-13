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

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        _state = EnumStop;
        _interval = 25;
    }
    
    return self;
}



@end
