//
//  CMHTMLReportBuilder.h
//  xcsummary
//
//  Created by Kryvoblotskyi Sergii on 12/13/16.
//  Copyright © 2016 MacPaw inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMTestableSummary, CMTest, JSONTestResultParser;
@interface CMHTMLReportBuilder : NSObject

/**
 Designated initializer

 @param path NSString attachments path
 @param resultsPath NSString
 @param showSuccessTests BOOL
 @return CMHTMLReportBuilder
 */
- (instancetype)initWithAttachmentsPath:(NSString *)path
                            resultsPath:(NSString *)resultsPath
                  testInformationParser:(JSONTestResultParser *)testInformationParser
                       showSuccessTests:(BOOL)showSuccessTests
                     excludedTestBundle:(NSString *)excludedTestBundle
                             executedBy:(NSString *)executedBy;

/**
 Appends summaries info as a header

 @param summaries NSArray <CMTestableSummary *> *
 */
- (void)appendSummaries:(NSArray <CMTestableSummary *> *)summaries;

/**
 Appends tests to the html template

 @param tests NSArray
 @param indentation CGGloat
 */
- (void)appendTests:(NSArray <CMTest *> *)tests indentation:(CGFloat)indentation;

/**
 Builds a compilted html page

 @return NSString
 */
- (NSString *)build;

@end
