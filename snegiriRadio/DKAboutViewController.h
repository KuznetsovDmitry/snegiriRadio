//
//  DKAboutViewController.h
//  snegiriRadio
//
//  Created by Grasshopper! on 22.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DKAboutViewControllerDelegate;

@interface DKAboutViewController : UIViewController

@property (assign) id <DKAboutViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UIButton *vkButton;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UIButton *instaButton;

@property (getter = isWhite) BOOL color;

- (IBAction)done;
- (IBAction)vkButtonPressed:(id)sender;
- (IBAction)fbButtonPressed:(id)sender;
- (IBAction)instaButtonPressed:(id)sender;

@end

@protocol DKAboutViewControllerDelegate

- (void)aboutViewControllerDidFinish:(DKAboutViewController *)controller;

@end
