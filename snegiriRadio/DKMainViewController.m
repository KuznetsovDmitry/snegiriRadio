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

@interface DKMainViewController ()
- (void)authorize;
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

- (void)viewDidLoad
{
    NSLog(@"- (void)viewDidLoad");
    [super viewDidLoad];
    
    VKAccessToken *token =[VKAccessToken tokenFromDefaults:TOKEN_KEY];
    [VKSdk initializeWithDelegate:self andAppId:APP_ID andCustomToken:[VKAccessToken tokenFromDefaults:TOKEN_KEY]];
    if (token == nil) {
        [self authorize];
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
                                                    @"count"    : @"10"}
                                    andHttpMethod:@"GET"];
    
    [self.loadingIndicator startAnimating];
    [request executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
        [self.loadingIndicator stopAnimating];
    } errorBlock:^(VKError *error) {
        NSLog(@"ERROR CODE: %d", error.errorCode);
        [error.request repeat];
    }];
    
    [self.artistTitle setText:[NSString stringWithFormat:@"Снегири"]];
    [self.trackTitle setText:[NSString stringWithFormat:@"Space"]];
   // [[self title] setText:[NSString stringWithFormat:@"\u0414\u0435\u043a\u0430\u0431\u0440\u044f"]];
}
@end
