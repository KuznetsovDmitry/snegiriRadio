//
//  DKColorViewController.m
//  snegiriRadio
//
//  Created by Grasshopper! on 22.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import "DKColorViewController.h"
#import "DKMainViewController.h"

@interface DKColorViewController ()
- (IBAction)whiteColor:(id)sender;
- (IBAction)blackColor:(id)sender;
- (void)addChildControllerWithColor:(BOOL)color;
@end

@implementation DKColorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildControllerWithColor:(BOOL)color {
    DKMainViewController *mainController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mainController = [[DKMainViewController alloc] initWithNibName:@"DKMainViewController_iPhone" bundle:nil];
    } else {
        mainController = [[DKMainViewController alloc] initWithNibName:@"DKMainViewController_iPad" bundle:nil];
    }
    
    mainController.color = color;
    
	mainController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _mainViewController = mainController;
	[self presentViewController:mainController animated:YES completion:nil];
}

- (IBAction)whiteColor:(id)sender {
    [self addChildControllerWithColor:YES];
}

- (IBAction)blackColor:(id)sender {
    [self addChildControllerWithColor:NO];
}
@end
