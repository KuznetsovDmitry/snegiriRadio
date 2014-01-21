//
//  DKMainViewController.h
//  snegiriRadio
//
//  Created by Grasshopper! on 14.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>

@interface DKMainViewController : UIViewController <VKSdkDelegate>

@property (retain, nonatomic) IBOutlet UILabel *trackTitle;
@property (retain, nonatomic) IBOutlet UILabel *artistTitle;

- (IBAction)getMusic:(id)sender;
@end
