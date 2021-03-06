//
//  CMHTMLReportBuilder.m
//  xcsummary
//
//  Created by Kryvoblotskyi Sergii on 12/13/16.
//  Copyright © 2016 MacPaw inc. All rights reserved.
//

#import "CMHTMLReportBuilder.h"
#import "CMTest.h"
#import "CMTestableSummary.h"
#import "CMActivitySummary.h"
#import "TemplateGeneratedHeader.h"
#import "JSONTestResultParser.h"
#import "JSONTestInformation.h"

@interface CMHTMLReportBuilder ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *resultsPath;
@property (nonatomic, copy) NSString *htmlResourcePath;

@property (nonatomic, strong) NSMutableString *resultString;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic) BOOL showSuccessTests;
@property (nonatomic, strong) NSString *excludedTestBundle;
@property (nonatomic, strong) NSString *executedBy;

@property (nonatomic, strong) NSDateComponentsFormatter *timeFormatter;

@property (nonatomic, strong) JSONTestResultParser *testParser;

@end

@implementation CMHTMLReportBuilder

- (instancetype)initWithAttachmentsPath:(NSString *)path
                            resultsPath:(NSString *)resultsPath
                  testInformationParser:(JSONTestResultParser *)testInformationParser
                       showSuccessTests:(BOOL)showSuccessTests
                      excludedTestBundle:(NSString *)excludedTestBundle
                             executedBy:(NSString *)executedBy
{
    self = [super init];
    if (self)
    {
        _fileManager = [NSFileManager defaultManager];
        _path = path;
        _resultsPath = resultsPath;
        _htmlResourcePath = [[resultsPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"resources"];
        _resultString = [NSMutableString new];
        _showSuccessTests = showSuccessTests;
        _testParser = testInformationParser;
        _excludedTestBundle = excludedTestBundle;
        _executedBy = executedBy;
        [self _prepareResourceFolder];
    }
    return self;
}

- (NSDateComponentsFormatter *)timeFormatter
{
    if (!_timeFormatter)
    {
        NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleAbbreviated;
        formatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        _timeFormatter = formatter;
    }
    return _timeFormatter;
}

#pragma mark - Public

- (void)appendSummaries:(NSArray <CMTestableSummary *> *)summaries
{
    NSUInteger successfullTests = [[summaries valueForKeyPath:@"@sum.numberOfSuccessfulTests"] integerValue];
    NSUInteger failedTests = [[summaries valueForKeyPath:@"@sum.numberOfFailedTests"] integerValue];
 
    BOOL failuresPresent = failedTests > 0;
    NSString *templateFormat = [self _decodeTemplateWithName:SummaryTemplate];
    NSTimeInterval totalTime = [[summaries valueForKeyPath:@"@sum.totalDuration"] doubleValue];
    NSString *timeString = [self.timeFormatter stringFromTimeInterval:totalTime];
    NSString *header = [NSString stringWithFormat:templateFormat, successfullTests + failedTests, timeString, successfullTests, failuresPresent ? @"inline": @"none", failedTests, self.executedBy];
    [self.resultString appendString:header];
}

- (void)appendTests:(NSArray *)tests indentation:(CGFloat)indentation
{

    [tests enumerateObjectsUsingBlock:^(CMTest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        // Exclude the specified test bundle (e.g. UnitTests.xctest)
        if ([obj.testName isEqualToString:@"All tests"]) {
            CMTest *firstTest = obj.subTests.firstObject;

            if ([[firstTest testName] isEqualToString:_excludedTestBundle])
                return;
        }

        [self _appendTestCase:obj indentation:indentation];
        
        if (obj.subTests.count > 0)
        {
            [self appendTests:obj.subTests indentation:indentation + 50];
        }
        else
        {
            if (self.showSuccessTests == NO)
            {
                if (obj.status == CMTestStatusFailure)
                {
                    [self _appendActivities:obj.activities indentation:indentation + 50];
                }
            }
            else
            {
                [self _appendActivities:obj.activities indentation:indentation + 50];
            }
        }
    }];
}
- (NSString *)build
{
    NSString *templateFormat = [self _decodeTemplateWithName:Template];
    return [NSString stringWithFormat:templateFormat, self.resultString.copy];
}

#pragma mark - Private

- (NSString *)_decodeTemplateWithName:(NSString *)fileName
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fileName options:0];
    NSString *format = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return format;
}

- (void)_appendTestCase:(CMTest *)testCase indentation:(CGFloat)indentation
{
    NSString *templateFormat = [self _decodeTemplateWithName:TestCaseTemplate];
    
    JSONTestInformation *testInfo = [self.testParser informationForTest:testCase.testName];
    
    NSString *mcc = @"";
    NSString *summary = testCase.testName;
    NSString *scenario = @"";
    NSString *statusClass = (testCase.status == CMTestStatusFailure) ? @"failed" : @"passed";
    
    if (testCase.activities.count > 0) {
        scenario = [NSString stringWithFormat:@"<div class=\"test-scenario\">%@</div>", testInfo.scenario];
        mcc = [testInfo.mcc stringByAppendingString:@" : "];
        summary = testInfo.summary;
    }
    
    NSString *composedString = [NSString stringWithFormat:templateFormat, statusClass, indentation, mcc, summary, scenario, testCase.duration];
    [self.resultString appendString:composedString];
}

- (void)_appendActivities:(NSArray *)activities indentation:(CGFloat)indentation
{
    [activities enumerateObjectsUsingBlock:^(CMActivitySummary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.title isEqualToString:@"Synthesize event"])
            return;
        
        [self _appendActivity:obj indentation:indentation];
        [self _appendActivities:obj.subActivities indentation:indentation + 50];
    }];
}

- (void)_appendActivity:(CMActivitySummary *)activity indentation:(CGFloat)indentation
{
    NSString *templateFormat = nil;
    NSString *composedString = nil;
    if (activity.hasScreenshotData)
    {
        templateFormat = [self _decodeTemplateWithName:ActivityTemplateWithImage];
        NSString *imageName = [NSString stringWithFormat:@"Screenshot_%@.png", activity.uuid.UUIDString];
        NSString *fullPath = [self.path stringByAppendingPathComponent:imageName];
        
        [self.fileManager copyItemAtPath:fullPath toPath:[self.htmlResourcePath stringByAppendingPathComponent:imageName] error:nil];
        
        NSString *localImageName = [NSString stringWithFormat:@"resources/Screenshot_%@.png", activity.uuid.UUIDString];
        composedString = [NSString stringWithFormat:templateFormat, indentation, @"px", activity.title, activity.finishTimeInterval - activity.startTimeInterval, localImageName];
    }
    else
    {
        templateFormat = [self _decodeTemplateWithName:ActivityTemplateWithoutImage];
        composedString = [NSString stringWithFormat:templateFormat, indentation, @"px", activity.title, activity.finishTimeInterval - activity.startTimeInterval];
    }
    
    [self.resultString appendString:composedString];
}

#pragma mark - File Operations

- (void)_prepareResourceFolder
{
    if ([self.fileManager fileExistsAtPath:self.htmlResourcePath] == NO) {
        [self.fileManager createDirectoryAtPath:self.htmlResourcePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

@end
