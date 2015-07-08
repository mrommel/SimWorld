//
//  AboutViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 22.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "AboutViewController.h"

#import "UIConstants.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.title = SWLocalizedString(@"TXT_KEY_MAIN_ABOUT");
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, DEVICE_WIDTH - 40, DEVICE_HEIGHT - 70)];
    textLabel.text = SWLocalizedString(@"TXT_KEY_ABOUT_TEXT");
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    [self.view addSubview:textLabel];
}

@end
