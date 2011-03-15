//
//  CWNSErrorTests.m
//  Zangetsu
//
//  Created by Colin Wheeler on 3/14/11.
//  Copyright 2011. All rights reserved.
//

#import "CWNSErrorTests.h"
#import "CWErrorUtilities.h"
#import "CWMacros.h"

@implementation CWNSErrorTests

-(void)testCreateError
{	
	NSError *error1 = CWCreateError(101, @"com.something.something", @"Some Message");
	
	NSError *error2 = [NSError errorWithDomain:@"com.something.something" code:101 userInfo:NSDICT(@"Some Message",NSLocalizedDescriptionKey)];
	
	STAssertTrue([error1 code] == [error2 code], @"Error 1 and 2 codes should be the same");
	STAssertTrue([[error1 domain] isEqualToString:[error2 domain]], @"Error1 and 2 domains should be the same");
	
	NSString *error1Message = [[error1 userInfo] valueForKey:NSLocalizedDescriptionKey];
	NSString *error2Message = [[error2 userInfo] valueForKey:NSLocalizedDescriptionKey];
	
	STAssertTrue([error1Message isEqualToString:error2Message], @"Error1 and Error2 Message should be the same");
}

-(void)testCreateErrorV
{
	int number = 5;
	NSError *error1 = CWCreateErrorV(101, @"com.something.something", @"An Error Code %i",number);
	
	NSString *msg = [NSString stringWithFormat:@"An Error Code %i",number];
	NSError *error2 = [NSError errorWithDomain:@"com.something.something" code:101 userInfo:NSDICT(msg, NSLocalizedDescriptionKey)];
	
	STAssertTrue([error1 code] == [error2 code], @"Error 1 and 2 codes should be the same");
	STAssertTrue([[error1 domain] isEqualToString:[error2 domain]], @"Error1 and 2 domains should be the same");
	
	NSString *error1Message = [[error1 userInfo] valueForKey:NSLocalizedDescriptionKey];
	NSString *error2Message = [[error2 userInfo] valueForKey:NSLocalizedDescriptionKey];
	
	STAssertTrue([error1Message isEqualToString:error2Message], @"Error1 and Error2 Message should be the same");
}

@end
