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
    
    if (![self isWhite]) {
        self.view.backgroundColor = [UIColor blackColor];
        
        self.label1.textColor = [UIColor whiteColor];
        self.label1.backgroundColor = [UIColor blackColor];
        self.label2.textColor = [UIColor whiteColor];
        self.label2.backgroundColor = [UIColor blackColor];
        
        [self.navigationBar setBarTintColor:[UIColor blackColor]];
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.logo.image = [UIImage imageNamed:@"logo_white.png"];
            [self.vkButton setImage:[UIImage imageNamed:@"vk_iphone_black.png"] forState:UIControlStateNormal];
            [self.fbButton setImage:[UIImage imageNamed:@"facebook_iphone_black.png"] forState:UIControlStateNormal];
            [self.instaButton setImage:[UIImage imageNamed:@"instagram_iphone_black.png"] forState:UIControlStateNormal];
        } else {
            self.logo.image = [UIImage imageNamed:@"logo_white_iPad.png"];
            [self.vkButton setImage:[UIImage imageNamed:@"vk_iPad_black.png"] forState:UIControlStateNormal];
            [self.fbButton setImage:[UIImage imageNamed:@"facebook_iPad_black.png"] forState:UIControlStateNormal];
            [self.instaButton setImage:[UIImage imageNamed:@"instagram_iPad_black.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
	[[self delegate] aboutViewControllerDidFinish:self];
}

- (IBAction)vkButtonPressed:(id)sender {
	NSURL *vkURL = [NSURL URLWithString:@"vk://vk.com/snegiri_rock"];
	if ([[UIApplication sharedApplication] canOpenURL:vkURL])
	{
		[[UIApplication sharedApplication] openURL:vkURL];
	}
	else
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://vk.com/snegiri_rock"]];
	}
}

- (IBAction)fbButtonPressed:(id)sender {
	NSURL *fbURL = [NSURL URLWithString:@"fb://profile/snegiri.radio"];
	if ([[UIApplication sharedApplication] canOpenURL:fbURL])
	{
		[[UIApplication sharedApplication] openURL:fbURL];
	}
	else
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/snegiri.radio"]];
	}
}

- (IBAction)instaButtonPressed:(id)sender {
	NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=snegiri_rock"];
	if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
	{
		[[UIApplication sharedApplication] openURL:instagramURL];
	}
	else
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://instagram.com/snegiri_rock"]];
	}
}

@end
