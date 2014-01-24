//
//  DKMainViewController.m
//  snegiriRadio
//
//  Created by Grasshopper! on 14.01.14.
//  Copyright (c) 2014 Kuznetsov Dmitry. All rights reserved.
//

#import "DKMainViewController.h"

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const APP_ID = @"4119359";

@interface DKMainViewController () <NCMusicEngineDelegate>
- (void)authorize;
- (void)nextTrack;
- (IBAction)showAbout:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
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

//изменить титульник
-(void)updateTitle:(NSString*)title {
	// update view text
//    title = [title stringByReplacingOccurrencesOfString:@"StreamTitle='(.*)';"
//                                             withString:@"$1"
//                                                options:NSRegularExpressionSearch
//                                                  range:NSMakeRange(0, [title length])];
//    [self.trackTitle setText:title];
}

//изменить кнопки
-(void)plaingChanged:(int)state {
// ИЗМЕНИТЬ КНОПКИ!!!
    
//    switch (state) {
//            // stop/pause
//        case 0:
//            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//                [self.radioButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:0];
//            } else {
//                [self.radioButton setImage:[UIImage imageNamed:@"playbutton-IPad.png"] forState:0];
//            }
//            break;
//            // loading
//        case 1:
//            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//                [self.radioButton setImage:[UIImage imageNamed:@"loadingbutton.png"] forState:0];
//            } else {
//                [self.radioButton setImage:[UIImage imageNamed:@"loadingbutton-IPad.png"] forState:0];
//            }
//            [self spinButton];
//            break;
//            // play
//        case 2:
//            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//                [self.radioButton setImage:[UIImage imageNamed:@"pausebutton.png"] forState:0];
//            } else {
//                [self.radioButton setImage:[UIImage imageNamed:@"pausebutton-IPad.png"] forState:0];
//            }
//            break;
//        default:
//            break;
//    }
//    
}

- (void)viewDidLoad
{
    NSLog(@"- (void)viewDidLoad");
    [super viewDidLoad];
    
    VKAccessToken *token =[VKAccessToken tokenFromDefaults:TOKEN_KEY];
    [VKSdk initializeWithDelegate:self andAppId:APP_ID andCustomToken:[VKAccessToken tokenFromDefaults:TOKEN_KEY]];
    if (token == nil) {
        [self authorize];
    }
    
    _player = [NCMusicEngine new];
    _player.delegate = self;
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
//    if (event.type == UIEventTypeRemoteControl) {
//        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
//            [self.radio updatePlay:YES];
//        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
//            [self.radio updatePlay:NO];
//        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
//            [self radioButtonPressed];
//        }
//    }
}

- (void)authorize
{
    NSLog(@"- (void)authorize");
    [VKSdk authorize:@[VK_PER_AUDIO] revokeAccess:YES];
}

- (IBAction)showAbout:(id)sender {
    DKAboutViewController *aboutController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([self isWhite]) {
            aboutController = [[DKAboutViewController alloc] initWithNibName:@"DKAboutViewController_iPhone_white" bundle:nil];
        } else {
           aboutController = [[DKAboutViewController alloc] initWithNibName:@"DKAboutViewController_iPhone_black" bundle:nil];
        }
    } else {
        //iPad
    }

    aboutController.delegate = self;
	
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

- (IBAction)getMusic:(id)sender {

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
    
    
    
   // [[self title] setText:[NSString stringWithFormat:@"\u0414\u0435\u043a\u0430\u0431\u0440\u044f"]];
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
    }
}

@end
