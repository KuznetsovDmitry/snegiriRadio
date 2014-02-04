//
//  DKMainViewController.m
//  snegiriRadio
//
//  Created by Grasshopper! on 14.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import "DKMainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const APP_ID = @"4119359";

@interface DKMainViewController () <NCMusicEngineDelegate, UIAlertViewDelegate> {
    BOOL _hasTrackList;
    BOOL _gettingTrackList;
    BOOL _errorOccured;
    int _errorsCount;
    BOOL _hasAccess;
    BOOL _firstPlay;
    BOOL _wasError;
}

- (void)authorize;
- (void)nextTrack;
- (void)reset;
- (void)errorHandle;
- (IBAction)showAbout:(id)sender;

- (void)setCentralButton:(BOOL)playButton;
@end

@implementation DKMainViewController

- (void)errorHandle {
    [self play:NO];
    [self setCentralButton:YES];
    if (_errorOccured) {
        if (self.alert == nil) {
            _wasError = YES;
            //        _errorOccured = YES;
            self.alert = [[UIAlertView alloc] initWithTitle:@"Unable To Play" message:@"We can't seem to play Radio at this moment. Please check your internet connection on your device and make sure you are either on a 3G or WiFi connection."
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.alert = nil;
    _errorOccured = NO;
    [self reset];
}

- (void)reset {
    [self setCentralButton:YES];
    [self.trackTitle setText:@""];
    [self.artistTitle setText:@""];
    
    
    NSArray *keys = [NSArray arrayWithObjects:
                     MPMediaItemPropertyTitle,
                     MPMediaItemPropertyArtist,
                     MPNowPlayingInfoPropertyPlaybackRate,
                     nil];
    NSArray *values = [NSArray arrayWithObjects:
                       @"",
                       @"",
                       [NSNumber numberWithInt:1],
                       nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    
    _isPlayed = NO;
    _gettingTrackList = NO;
    _errorsCount = 0;
}

- (void)setCentralButton:(BOOL)playButton {
    if (playButton) {
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
    } else {
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
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"- (void)viewDidLoad");
    [super viewDidLoad];
    
    [[self trackTitle] addSubview:[self loadingIndicator]];
    
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
    
    _player = [NCMusicEngine new];
    _player.delegate = self;
    _isPlayed = NO;
    _firstPlay = YES;
    _hasTrackList = NO;
    _gettingTrackList = NO;
    _errorsCount = 0;
    _errorOccured = NO;
    _hasAccess = NO;
    _firstPlay = YES;
    _wasError = NO;
    
    VKAccessToken *token =[VKAccessToken tokenFromDefaults:TOKEN_KEY];
    [VKSdk initializeWithDelegate:self
                         andAppId:APP_ID
                   andCustomToken:[VKAccessToken tokenFromDefaults:TOKEN_KEY]];
    if (token == nil) {
        [self authorize];
    }
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
    [VKSdk authorize:@[VK_PER_AUDIO, VK_PER_OFFLINE] revokeAccess:YES];
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
    _hasAccess = YES;
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    NSLog(@"- (void)vkSdkShouldPresentViewController:(UIViewController *)controller");
	[self presentViewController:controller animated:YES completion:nil];
    
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token {
    NSLog(@"- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token");
    _hasAccess = YES;
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    NSLog(@"- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError");
	[[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (IBAction)playButtonPressed:(id)sender {
    if (_hasAccess) {
        if (_firstPlay) {
            if (!_gettingTrackList) {
                [self setCentralButton:NO];
                _gettingTrackList = YES;
                VKRequest *request = [VKRequest requestWithMethod:@"audio.get"
                                                    andParameters:@{VK_API_OWNER_ID : @"-58215044",
                                                                    @"need_user": @"0",
                                                                    @"count"    : @"0"}
                                                    andHttpMethod:@"GET"];
                
                [self.loadingIndicator startAnimating];
                
                request.progressBlock = ^(VKProgressType progressType, long long bytesLoaded, long long bytesTotal) {
                    NSLog(@"loaded: %lld from: %lld", bytesLoaded, bytesTotal);
                };
                
                [request executeWithResultBlock:^(VKResponse * response) {
                    [self.loadingIndicator stopAnimating];
                    if (response.json == nil) {
                        _gettingTrackList = NO;
                        [self errorHandle];
                    } else {
                        _hasTrackList = YES;
                        _firstPlay = NO;
                        NSLog(@"Json result: %@", response.json);
                        self.musicList = [response.json objectForKey:@"items"];
                        [self nextTrack];
                    }
                } errorBlock:^(VKError *error) {
                    if (error.errorCode != VK_API_ERROR) {
                        ++_errorsCount;
                        if (_errorsCount < 3) {
                            [error.request repeat];
                        } else {
                            _gettingTrackList = NO;
                            [self.loadingIndicator stopAnimating];
                            [self errorHandle];
                        }
                    } else {
                        NSLog(@"VK error: %@", error.apiError);
                        _gettingTrackList = NO;
                        [self.loadingIndicator stopAnimating];
                        [self errorHandle];
                        [self authorize];
                    }
                }];
                
            }
        } else if(_wasError ) {
            _wasError = NO;
            [self nextTrack];
        } else if ([self isPlayed]) {
            [self setCentralButton:YES];
            [self.player pause];
        } else {
            [self setCentralButton:NO];
            [self.player resume];
        }

    } else {
        [self authorize];
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
        [self setCentralButton:NO];
        
        NSArray *keys = [NSArray arrayWithObjects:
                         MPMediaItemPropertyTitle,
                         MPMediaItemPropertyArtist,
                         MPNowPlayingInfoPropertyPlaybackRate,
                         nil];
        NSArray *values = [NSArray arrayWithObjects:
                           [obj valueForKey:@"title"],
                           [obj valueForKey:@"artist"],
                           [NSNumber numberWithInt:1],
                           nil];
        NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    }
}

- (void)engine:(NCMusicEngine *)engine didChangePlayState:(NCMusicEnginePlayState)playState {
    
    if (playState == NCMusicEnginePlayStateEnded) {
        [self setCentralButton:YES];
        [self nextTrack];
    } else if (playState == NCMusicEnginePlayStatePlaying) {
        [self setCentralButton:NO];
        [self volumeChanged:nil];
        [self play:YES];
    } else if (playState == NCMusicEnginePlayStatePaused) {
        [self setCentralButton:YES];
        [self play:NO];
    } else if (playState == NCMusicEnginePlayStateError) {
        [self setCentralButton:YES];
        [self play:NO];
        [self.player stop];
        _errorOccured = YES;
        [self errorHandle];
    }
}

- (void)engine:(NCMusicEngine *)engine didChangeDownloadState:(NCMusicEngineDownloadState)downloadState {
    if (downloadState == NCMusicEngineDownloadStateError) {
        _errorOccured = YES;
        [self errorHandle];
    }
}

@end
