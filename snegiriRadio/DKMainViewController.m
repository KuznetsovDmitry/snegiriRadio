//
//  DKMainViewController.m
//  snegiriRadio
//
//  Created by Grasshopper! on 14.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import "DKMainViewController.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const APP_ID = @"4119359";

@interface DKMainViewController () <NCMusicEngineDelegate>
- (void)authorize;
- (void)nextTrack;
- (IBAction)showAbout:(id)sender;
@end

@implementation DKMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"- (void)viewDidLoad");
    [super viewDidLoad];
    
    if (![self isWhite]) {
        self.view.backgroundColor = [UIColor blackColor];
        
        self.trackTitle.textColor = [UIColor whiteColor];
        self.trackTitle.backgroundColor = [UIColor blackColor];
        
        self.artistTitle.textColor = [UIColor whiteColor];
        self.artistTitle.backgroundColor = [UIColor blackColor];
        
        [self.loadingIndicator setColor:[UIColor whiteColor]];
        
        self.volumeSlider.minimumTrackTintColor = [UIColor redColor];
        self.volumeSlider.maximumTrackTintColor = [UIColor grayColor];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.playButton setImage:[UIImage imageNamed:@"play_iphone_black.png"] forState:UIControlStateNormal];
            
            [self.aboutButton setImage:[UIImage imageNamed:@"logo_about_white.png"] forState:UIControlStateNormal];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"play_ipad_black.png"] forState:UIControlStateNormal];
            
            [self.aboutButton setImage:[UIImage imageNamed:@"logo_about_white_iPad.png"] forState:UIControlStateNormal];
        }
    }
    
    VKAccessToken *token =[VKAccessToken tokenFromDefaults:TOKEN_KEY];
    [VKSdk initializeWithDelegate:self andAppId:APP_ID andCustomToken:[VKAccessToken tokenFromDefaults:TOKEN_KEY]];
    if (token == nil) {
        [self authorize];
    }
    
    _player = [NCMusicEngine new];
    _player.delegate = self;
    _isPlayed = NO;
    _firstPlay = YES;
    
    [[self player] volume:0.5f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self playButtonPressed:nil];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self playButtonPressed:nil];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self playButtonPressed:nil];
        }
    }
}

- (void)authorize
{
    NSLog(@"- (void)authorize");
    [VKSdk authorize:@[VK_PER_AUDIO] revokeAccess:YES];
}

- (IBAction)showAbout:(id)sender {
    DKAboutViewController *aboutController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        aboutController = [[DKAboutViewController alloc] initWithNibName:@"DKAboutViewController_iPhone" bundle:nil];
    } else {
        aboutController = [[DKAboutViewController alloc] initWithNibName:@"DKAboutViewController_iPad" bundle:nil];
    }

    aboutController.delegate = self;
    aboutController.color = _color;
	
	aboutController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentViewController:aboutController animated:YES completion:nil];
}

- (void)aboutViewControllerDidFinish:(DKAboutViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    NSLog(@"- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError");
	VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
	[vc presentIn:self];
    
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    NSLog(@"- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken");
	[self authorize];
    
}

- (void)vkSdkDidReceiveNewToken:(VKAccessToken *)newToken {
    NSLog(@"- (void)vkSdkDidReceiveNewToken:(VKAccessToken *)newToken");
	[newToken saveTokenToDefaults:TOKEN_KEY];
    
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    NSLog(@"- (void)vkSdkShouldPresentViewController:(UIViewController *)controller");
	[self presentViewController:controller animated:YES completion:nil];
    
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token {
    NSLog(@"- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token");

}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    NSLog(@"- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError");
	[[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
}

- (IBAction)playButtonPressed:(id)sender {
    if (![self isPlayed]) {
        if ([self isWhite]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.playButton setImage:[UIImage imageNamed:@"pause_iphone_white.png"] forState:UIControlStateNormal];
            } else {
                [self.playButton setImage:[UIImage imageNamed:@"pause_ipad_white.png"] forState:UIControlStateNormal];
            }
        } else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.playButton setImage:[UIImage imageNamed:@"pause_iphone_black.png"] forState:UIControlStateNormal];
            } else {
                [self.playButton setImage:[UIImage imageNamed:@"pause_ipad_black.png"] forState:UIControlStateNormal];
            }
        }
        if ([self firstPlay]) {
            self.firstPlay = NO;
            VKRequest *request = [VKRequest requestWithMethod:@"audio.get"
                                                andParameters:@{VK_API_OWNER_ID : @"-58215044",
                                                                @"need_user": @"0",
                                                                @"count"    : @"0"}
                                                andHttpMethod:@"GET"];
            
            [self.loadingIndicator startAnimating];
            [request executeWithResultBlock:^(VKResponse * response) {
                NSLog(@"Json result: %@", response.json);
                self.musicList = [response.json objectForKey:@"items"];
                [self.loadingIndicator stopAnimating];
                [self nextTrack];
            } errorBlock:^(VKError *error) {
                NSLog(@"ERROR CODE: %d", error.errorCode);
                [error.request repeat];
            }];
        } else {
            [self.player resume];
        }
	} else {
        if ([self isWhite]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.playButton setImage:[UIImage imageNamed:@"play_iphone_white.png"] forState:UIControlStateNormal];
            } else {
                [self.playButton setImage:[UIImage imageNamed:@"play_ipad_white.png"] forState:UIControlStateNormal];
            }
        } else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.playButton setImage:[UIImage imageNamed:@"play_iphone_black.png"] forState:UIControlStateNormal];
            } else {
                [self.playButton setImage:[UIImage imageNamed:@"play_ipad_black.png"] forState:UIControlStateNormal];
            }
        }
        [self.player pause];
	}
}

- (IBAction)volumeChanged:(id)sender {
    [[self player] volume:self.volumeSlider.value];
}

- (void)nextTrack {
    if ([_musicList count] > 0) {
        NSDictionary *obj = _musicList[arc4random_uniform([_musicList count])];
        [_player playUrl:[NSURL URLWithString:[obj valueForKey:@"url"]]];
        [self.artistTitle setText:[obj valueForKey:@"artist"]];
        [self.trackTitle setText:[obj valueForKey:@"title"]];
    }
}

- (void)engine:(NCMusicEngine *)engine didChangePlayState:(NCMusicEnginePlayState)playState {

    if (playState == NCMusicEnginePlayStateEnded) {
        [self nextTrack];
    } else if (playState == NCMusicEnginePlayStatePlaying) {
        [self play:YES];
    } else if (playState == NCMusicEnginePlayStatePaused) {
        [self play:NO];
    }
}

@end
