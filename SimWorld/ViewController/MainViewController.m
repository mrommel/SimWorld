//
//  MainViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 06.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "MainViewController.h"

#import "UIConstants.h"
#import "XMLReader.h"
#import "HexagonMap.h"
#import "UIBlockButton.h"
#import "UIConstants.h"

#import "LoadingViewController.h"
#import "SetupGameStep1ViewController.h"
#import "AboutViewController.h"

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, DEVICE_WIDTH, 180)];
    [imageView setImage:[UIImage imageNamed:@"CivilizationV_byWar36.png"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:imageView];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"SimWorld"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
    
    __weak typeof(self) weakSelf = self;
    [self addButton:SWLocalizedString(@"TXT_KEY_MAIN_SETUP") atY:300 withBlock:^{
        [weakSelf navigateToSetup];
    }];
    [self addButton:SWLocalizedString(@"TXT_KEY_MAIN_LOAD_MAP") atY:370 withBlock:^{
        [weakSelf navigateToLoading];
    }];
    
    [self addButton:SWLocalizedString(@"TXT_KEY_MAIN_ABOUT") atY:510 withBlock:^{
        [weakSelf navigateToAbout];
    }];
}

- (void)navigateToSetup
{
    SetupGameStep1ViewController *viewController = [[SetupGameStep1ViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)navigateToLoading
{
    LoadingViewController *viewController = [[LoadingViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)navigateToAbout
{
    AboutViewController *viewController = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)addButton:(NSString *)title atY:(int)y withBlock:(ActionBlock)action
{
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    UIBlockButton *newButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [newButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [newButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [newButton handleControlEvent:UIControlEventTouchUpInside
                        withBlock:action];
    [newButton setTitle:title forState:UIControlStateNormal];
    newButton.frame = CGRectMake(BU, y, DEVICE_WIDTH - BU2, 40);
    [self.view addSubview:newButton];
}

@end
