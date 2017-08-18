//
//  JSONTestResultParser.h
//  XCSummary
//
//  Created by Nolan Carroll on 8/17/17.
//  Copyright © 2017 MacPaw inc. All rights reserved.
//

#ifndef JSONTestResultParser_h
#define JSONTestResultParser_h

@class JSONTestInformation;
@interface JSONTestResultParser : NSObject

- (instancetype)initWithFilePath:(NSString *)path;

- (JSONTestInformation *)informationForTest:(NSString *)testName;

@end

#endif /* JSONTestResultParser_h */
