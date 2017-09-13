//
//  JSONTestResultParser.m
//  XCSummary
//
//  Created by Nolan Carroll on 8/17/17.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONTestResultParser.h"
#import "JSONTestInformation.h"

@implementation JSONTestResultParser {
    NSDictionary *testInformation;
}

- (instancetype)initWithFilePath:(NSString *)path {
    self = [super init];
    
    if (self) {
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
        
        NSError *jsonError;
        testInformation = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];        
    }

    return self;
}

- (JSONTestInformation *)informationForTest:(NSString *)testName {
    NSDictionary *testDetails = testInformation[testName];
    JSONTestInformation *info = [[JSONTestInformation alloc] initWithName:testDetails[@"Name"] mcc:testDetails[@"MCC"] scenario:testDetails[@"Scenario"] tags:testDetails[@"Tags"]];
    
    return info;
}

- (NSString *)descriptionForTest:(NSString *)testName {
    NSDictionary *testDetails = testInformation[testName];
    NSString *description = testDetails[@"Description"];
    return description;
}

@end
