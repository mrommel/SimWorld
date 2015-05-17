//
//  AsyncTask.h
//  Staff5Personal
//
//  Created by Mansour Boutarbouch Mhaimeur on 25/10/13.
//  Copyright (c) 2013 Smart & Artificial Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AsyncTaskDelegate;

@interface AsyncTask : NSObject

@property (nonatomic, weak) id<AsyncTaskDelegate> delegate;

- (id)initWithDelegate:(id<AsyncTaskDelegate>) delegate;

- (void)executeParameters:(NSDictionary *)params;
- (void)preExecute;
- (NSInteger)doInBackground: (NSDictionary *)parameters;
- (void)postExecute:(NSInteger)result;

- (void)updateProgress:(int)progress;

@end

@protocol AsyncTaskDelegate <NSObject>

@optional
- (void)asyncTask:(AsyncTask*)asyncTask didUpdateProgress:(int)value;
- (void)asyncTask:(AsyncTask*)asyncTask finishedWithSuccess:(BOOL)success;

@end
