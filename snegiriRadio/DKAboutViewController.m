//
//  DKAboutViewController.m
//  snegiriRadio
//
//  Created by Grasshopper! on 22.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import "DKAboutViewController.h"

@interface DKAboutViewController ()

@end

@implementation DKAboutViewController

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

- (IBAction)done {
	[[self delegate] aboutViewControllerDidFinish:self];
}

@end
