//
//  LauncherViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 18.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "LauncherViewController.h"

#import "HexagonMapManager.h"
#import "MainViewController.h"
#import "CircularProgressView.h"
#import "UIConstants.h"
#import "HexagonMap.h"

@interface LauncherTask : AsyncTask {
    
}

@end

@implementation LauncherTask

- (void)preExecute
{
    //Method to override
}

- (NSInteger)doInBackground:(NSArray *)parameters
{
    [self updateProgress:0];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"maps" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *maps = [[NSArray alloc] initWithArray:[dictionary valueForKey:@"Maps"]];
    
    for (NSDictionary *map in maps) {
        NSString *mapName = [map objectForKey:@"Map"];
        [[HexagonMapManager sharedInstance] registerMap:mapName];
        NSLog(@"Registered Map: %@", mapName);
    }
    
    [self updateProgress:20];
    
    NSUInteger itemCount = [[HexagonMapManager sharedInstance].items count], i = 0;
    for (HexagonMapManagerItem *item in [HexagonMapManager sharedInstance].items) {
        HexagonMap *map = [[HexagonMap alloc] initWithCiv5Map:item.name];
        item.title = item.name;//map.name;
        item.text = map.text;
        item.image = [map thumbnail];
        
        [NSThread sleepForTimeInterval:.5];
        i++;
        [self updateProgress:((float)i / (float)itemCount) * 80 + 20];
    }
    
    return 1;
}

- (void)postExecute:(NSInteger)result
{
    NSLog(@"Finished with status: %ld", result);
    if (result == 1) {
        
    } else {
        
    }
}

@end

// -----------------------------------------

@interface LauncherViewController () {
    CircularProgressView *_progressView;
}

@end

@implementation LauncherViewController

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
    [[[LauncherTask alloc] initWithDelegate:self] executeParameters:nil];
}

- (void)moveToMainMenu
{
    MainViewController *viewController = [[MainViewController alloc] init];
    viewController.title = @"SimWorld";
    [self.navigationController pushViewController:viewController animated:YES];
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
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self moveToMainMenu];
    });
}

@end
