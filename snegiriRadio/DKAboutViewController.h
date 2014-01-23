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

- (IBAction)done;

@end

@protocol DKAboutViewControllerDelegate

- (void)aboutViewControllerDidFinish:(DKAboutViewController *)controller;

@end
