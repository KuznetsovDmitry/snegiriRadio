//
//  DKMainViewController.h
//  snegiriRadio
//
//  Created by Grasshopper! on 14.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKSdk.h"
#import "DKAboutViewController.h"
#import "NCMusicEngine.h"

@interface DKMainViewController : UIViewController <VKSdkDelegate, DKAboutViewControllerDelegate>

//-----------------------------------------------------

@property (nonatomic, strong) NCMusicEngine *player;


//-----------------------------------------------------

@property (strong) NSArray *musicList;
@property (getter = isWhite) BOOL color;
@property (nonatomic, setter = play:) BOOL isPlayed;
@property (nonatomic) BOOL firstPlay;
@property (strong, nonatomic) UIAlertView *alert;

@property (retain, nonatomic) IBOutlet UILabel *trackTitle;
@property (retain, nonatomic) IBOutlet UILabel *artistTitle;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)volumeChanged:(id)sender;

@end
