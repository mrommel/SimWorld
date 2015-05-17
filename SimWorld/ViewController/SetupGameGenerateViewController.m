//
//  SetupGameGenerateViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 21.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "SetupGameGenerateViewController.h"

#import "SetupGameStepContent.h"
#import "HexagonMap.h"
#import "HexagonMapManager.h"
#import "AsyncTask.h"
#import "HeightMap.h"
#import "HexagonMapItem.h"
#import "CC3Math.h"

#import "GameViewController.h"
#import "CircularProgressView.h"
#import "UIConstants.h"
#import "GenerateMapTask.h"

// -----------------------------------------

@interface SetupGameGenerateViewController () {
    CircularProgressView *_progressView;
}

@end

@implementation SetupGameGenerateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _progressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(20, 100, DEVICE_WIDTH - 40, DEVICE_WIDTH - 40)];
    [_progressView setPercent:0];
    [self.view addSubview:_progressView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSNumber numberWithInt:kNumberOfLakes] forKey:kParamNumberOfLakes];
    [parameters setObject:[NSNumber numberWithInt:kNumberOfRivers] forKey:kParamNumberOfRivers];
    [[[GenerateMapTask alloc] initWithDelegate:self] executeParameters:parameters];
}

- (void)asyncTask:(AsyncTask*)asyncTask didUpdateProgress:(int)value
{
    NSLog(@"Show progress: %d", value);
    dispatch_async(dispatch_get_main_queue(), ^(){
        [_progressView setPercent:value];
    });
}

- (void)asyncTask:(AsyncTask*)asyncTask finishedWithSuccess:(BOOL)success
{
    NSLog(@"Finished with success: %d", success);
    GenerateMapTask *generateMapTask = (GenerateMapTask *)asyncTask;
    HexagonMap *map = generateMapTask.map;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self moveToOpenGLWithMap:map];
    });
}

- (void)moveToOpenGLWithMap:(HexagonMap *)map
{
    //OpenGLViewController *viewController = [[OpenGLViewController alloc] init];
    GameViewController *viewController = [[GameViewController alloc] init];
    viewController.title = @"Generated";
    viewController.map = map;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
