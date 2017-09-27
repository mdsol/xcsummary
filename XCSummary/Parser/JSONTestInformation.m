//
//  JSONTestInformation.m
//  XCSummary
//
//  Created by Nolan Carroll on 8/17/17.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONTestInformation.h"

@implementation JSONTestInformation

- (id)initWithName:(NSString *)name mcc:(NSString *)mcc summary:(NSString *)summary scenario:(NSString *)scenario tags:(NSString *)tags {
    
    self = [super init];
    
    if (self) {
        _name = name;
        _summary = summary;
        _mcc = mcc;
        _scenario = scenario;
        _tags = tags;
    }
    
    return self;
}

@end
