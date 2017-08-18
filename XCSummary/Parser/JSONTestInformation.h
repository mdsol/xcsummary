//
//  JSONTestInformation.h
//  XCSummary
//
//  Created by Nolan Carroll on 8/17/17.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#ifndef JSONTestInformation_h
#define JSONTestInformation_h

@interface JSONTestInformation : NSObject 

@property NSString * name;
@property NSString * mcc;
@property NSString * scenario;
@property NSString * tags;

- (id)initWithName:(NSString *)name mcc:(NSString *)mcc scenario:(NSString *)scenario tags:(NSString *)tags;

@end

#endif /* JSONTestInformation_h */
