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

- (IBAction)whiteColor:(id)sender {
    DKMainViewController *mainController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mainController = [[DKMainViewController alloc] initWithNibName:@"DKMainViewController_iPhone_white" bundle:nil];
    } else {
       //iPad
    }
	
    mainController.color = YES;
	mainController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentViewController:mainController animated:YES completion:nil];
}

- (IBAction)blackColor:(id)sender {
    DKMainViewController *mainController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mainController = [[DKMainViewController alloc] initWithNibName:@"DKMainViewController_iPhone_black" bundle:nil];
    } else {
        //iPad
    }
    
    mainController.color = NO;
	mainController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentViewController:mainController animated:YES completion:nil];
}
@end