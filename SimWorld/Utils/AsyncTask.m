//
//  AsyncTask.m
//  Staff5Personal
//
//  Created by Mansour Boutarbouch Mhaimeur on 25/10/13.
//  Copyright (c) 2013 Smart & Artificial Technologies. All rights reserved.
//

#import "AsyncTask.h"

@implementation AsyncTask

- (id)initWithDelegate:(id<AsyncTaskDelegate>) delegate
{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)executeParameters:(NSDictionary *)params
{
    [self preExecute];
    __block NSInteger result;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        result = [self doInBackground:params];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postExecute:result];
            
            id<AsyncTaskDelegate> strongDelegate = self.delegate;
            
            // Our delegate method is optional, so we should
            // check that the delegate implements it
            if ([strongDelegate respondsToSelector:@selector(asyncTask:finishedWithSuccess:)]) {
                [strongDelegate asyncTask:self finishedWithSuccess:(result == 1)];
            }
        });
    });
}

- (void)preExecute
{
    //Method to override
    //Run on main thread (UIThread)
}

- (NSInteger)doInBackground:(NSDictionary *)parameters
{
    //Method to override
    //Run on async thread (Background)
    return 0;
}

- (void)updateProgress:(int)progress
{
    id<AsyncTaskDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(asyncTask:didUpdateProgress:)]) {
        [strongDelegate asyncTask:self didUpdateProgress:progress];
    }
}

- (void)postExecute:(NSInteger)result
{
    //Method to override
    //Run on main thread (UIThread)
}

@end
