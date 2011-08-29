//
//  CWURLRequest.m
//  Zangetsu
//
//  Created by Colin Wheeler on 8/13/11.
//  Copyright 2011. All rights reserved.
//

#import "CWURLRequest.h"

@interface CWURLRequest()
@property(nonatomic, retain, readwrite) NSString *host;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSURLRequest *urlRequest;
@property(nonatomic, retain) NSMutableData *urlData;
@property(nonatomic, assign) BOOL isFinished;
@property(nonatomic, retain) NSError *urlError;
@end

@implementation CWURLRequest

@synthesize host;
@synthesize connection;
@synthesize urlRequest;
@synthesize urlData;
@synthesize isFinished;
@synthesize urlError;

-(id)init {
    self = [super init];
    if (self) {
        host = nil;
        connection = nil;
        urlRequest = nil;
        urlData = nil;
        isFinished = NO;
        urlError = nil;
    }
    return self;
}

-(id)initWithURLString:(NSString *)urlHost
{
    self = [super init];
    if (self) {
        host = urlHost;
        connection = nil;
        urlRequest = nil;
        urlData = [[NSMutableData alloc] init];
        isFinished = NO;
        urlError = nil;
    }
    
    return self;
}

/**
 synchronously starts the connection and waits for it to finish setting ourself as the delegate
 then executes the block when completed
 
 @param block the block to be executed once the NSURLRequest has completed
 */
-(void)startSynchronousDownloadWithCompletionBlock:(void (^)(NSData *data, NSError *error))block {
    NSParameterAssert([self host]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:CWURL([self host])];
    [self setUrlRequest:request];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self setConnection:urlConnection];
    
    [urlConnection start];
    
    while ([self isFinished] == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }
    
    block([self urlData],[self urlError]);
}

/**
 creates the urlrequest and then starts the connection on a gcd queue and waits till it has
 finished and then executes the block on the main thread
 
 @param queue a gcd queue ( dispatch_queue_t ) to execute the block on, must not be NULL
 @param block a block to be executed on the main thread once the connection has finished
 */
-(void)startAsynchronousDownloadOnQueue:(dispatch_queue_t)queue
                    withCompletionBlock:(void (^)(NSData *data, NSError *error))block {
    NSParameterAssert([self host]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:CWURL([self host])];
    [self setUrlRequest:request];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self setConnection:urlConnection];
    
    dispatch_async(queue, ^(void) {
        [urlConnection start];
        
        while ([self isFinished] == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            block([self urlData],[self urlError]);
        });
    });
}

/**
 creates the urlrequest and then starts the connection on a NSOperationQueue and waits till it has
 finished and then executes the block on the main thread
 
 @param queue a NSOperationQueue to execute the block on, must not be NULL
 @param block a block to be executed on the main thread once the connection has finished
 */
-(void)startAsynchronousDownloadOnNSOperationQueue:(NSOperationQueue *)queue
                               withCompletionBlock:(void (^)(NSData *data, NSError *error))block {
    NSParameterAssert([self host]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:CWURL([self host])];
    [self setUrlRequest:request];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self setConnection:urlConnection];
    
    [queue addOperationWithBlock:^(void) {
        
        [urlConnection start];
        
        while ([self isFinished] == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
            block([self urlData],[self urlError]);
        }];
    }];
}

//MARK: -
//MARK: NSURLConnection Delegate Methods

- (NSURLRequest *)connection:(NSURLConnection *)inConnection 
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse) {
        NSMutableURLRequest *req = [self->urlRequest mutableCopy];
        [req setURL:[request URL]];
        [self setUrlRequest:req];
        return [self urlRequest];
    } else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)data {
    [[self urlData] appendData:data];
}

/**
 if the connection is ours then mark ourselfs as finished and exit
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection {
    if ([[self connection] isEqual:inConnection]) {
        [self setIsFinished:YES];
    }
}

/**
 mark ourself as finished and copy the error before we finish....
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self setUrlError:[error copy]];
    [self setIsFinished:YES];
}

@end
