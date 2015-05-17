//
//  OpenGLViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 04.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "_OpenGLViewController.h"

#import "UIConstants.h"
#import "MainViewController.h"

@interface _OpenGLViewController ()

@end

@implementation _OpenGLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setTitle:@"Main"];
    
    // change the back button to cancel and add an event handler
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(backButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.glView = [[OpenGLView alloc] initWithMap:self.map];
    [self.view addSubview:self.glView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.glView detachDisplayLink];
    [self.glView removeFromSuperview];
    self.glView = nil;
}

- (void)backButtonPressed:(id)sender {
    NSLog(@"back button pressed");
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++){
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[MainViewController class]]){
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }}

@end
