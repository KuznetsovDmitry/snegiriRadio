vk-ios-sdk
==========

Library for working with VK API, authorization through VK app, using VK functions.

Prepare for Using VK SDK
----------

To use VK SDK primarily you need to create a new VK application [here](https://vk.com/editapp?act=create) by choosing the Standalone application type. Choose a title and confirm the action via SMS and you will be redirected to the application settings page. 
You will require your Application ID (referenced as API_ID in the documentation). Fill in the App Bundle for iOS field. 

Setup URL-schema of Your Application
----------

To use authorization via VK App you need to setup a url-schema of your application. 

<b>Xcode 5:</b>
Open your application settings then select the Info tab. In the URL Types section click the plus sign. Enter vk+APP_ID (e.g. vk1234567) to the Identifier and URL Schemes fields.

<b>Xcode 4:</b>
Open your Info.plist then add a new row URL Types. Set the URL identifier to vk+APP_ID

Adding VK iOS SDK to your iOS application
==========

Installation with CocoaPods
----------

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like VK SDK in your projects. See the "[Getting Started](http://beta.cocoapods.org/?q=#get_started)" guide for more information.

Podfile

    platform :ios, '5.0'
    pod "VK-ios-sdk"
    
Then import the main header.

    #import <VKSdk.h>

Installation with source code
----------

Add the sdk/sdk.xcodeproj file to your project. In the Application settings open Build phases, then the Link Binary with Libraries section. Add libVKSdk.a there, then import the main header.

    #import "VKSdk.h"

Using SDK
==========
SDK Initialization
----------
1) Put this code to the application delegate method  application:openURL:sourceApplication:annotation:
```
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}
```
2) Initialize SDK with your APP_ID for any delegate.
    [VKSdk initialize:delegate andAppId:YOUR_APP_ID];
    
See full description of VKSdkDelegate protocol here: http://vkcom.github.io/vk-ios-sdk/Protocols/VKSdkDelegate.html

User Authorization
----------

There are several methods for authorization: 

    [VKSdk authorize:scope];
    [VKSdk authorize:scope revokeAccess:YES];
    [VKSdk authorize:scope revokeAccess:YES forceOAuth:YES];

Generally, [VKSdk authorize:scope]; is enough for your needs. 

When succeeded, the following method of delegate will be called:

    -(void) vkSdkDidReceiveNewToken:(VKAccessToken*) newToken;

In case of error (e.g., user canceled authorization):

    -(void) vkSdkUserDeniedAccess:(VKError*) authorizationError;

API Requests
==========

Requests Syntax
----------
Below we have listed the examples for several request types. 
1) Plain request.

    VKRequest * audioReq = [[VKApi users] get];

2) Request with parameters.

    VKRequest * audioReq = [[VKApi audio] get:@{VK_OWNER_ID : @"896232"}];

3) Http (not https) request (only if scope VK_PER_NOHTTPS has been passed)

    VKRequest * audioReq = [[VKApi audio] get:@{VK_OWNER_ID : @"896232"}]; 
    audioReq.secure = NO;

4) Request with predetermined maximum number of attempts.

    VKRequest * postReq = [[VKApi wall] post:@{VK_MESSAGE : @"Test"}]; 
    postReq.attempts = 10; 
    //or infinite 
    //postReq.attempts = 0;

It will take 10 attempts until succeeds or an API error occurs. 

5) Request that calls a method of VK API (keep in mind scope value).

    VKRequest * getWall = [VKRequest requestWithMethod:@"wall.get" andParameters:@{VK_API_OWNER_ID : @"-1"} andHttpMethod:@"GET"];

6) Request for uploading photos on user wall.

    VKRequest * request = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"my_photo"] parameters:[VKImageParameters pngImage] userId:0 groupId:0 ];

Requests Sending
----------

    [audioReq executeWithResultBlock:^(VKResponse * response) { 
            NSLog(@"Json result: %@", response.json); 
        } errorBlock:^(VKError * error) { 
        if (error.code != VK_API_ERROR) { 
            [error.request repeat]; 
        } else { 
            NSLog(@"VK error: %@", error.apiError); 
        } 
    }];

Error Handling
----------
The VKError class contains the errorCode property. Compare its value with the global constant VK_API_ERROR. If it equals, process the vkError field that contains a description of a VK API error. Otherwise you should handle an http error in the httpError property. 

Some errors (e.g., captcha error, validation error) can be proccessed by the SDK. Appropriate delegate methods will be called for this purpose. 
Below is an example of captcha error processing:

    -(void) vkSdkNeedCaptchaEnter:(VKError*) captchaError 
    { 
        VKCaptchaViewController * vc = [VKCaptchaViewController captchaControllerWithError:captchaError]; 
        [vc presentIn:self]; 
    }

Batch Processing Requests
----------
SDK gives a feature to execute several unrelated requests at the one call. 

1) Prepare requests
```
VKRequest * request1 = [[VKApi audio] get]; 
request1.completeBlock = ^(VKResponse*) { ... }; 

VKRequest * request2 = [[VKApi users] get:@{VK_USER_IDS : @[@(1), @(6492), @(1708231)]}]; 
request2.completeBlock = ^(VKResponse*) { ... };
```
2) Combine created requests into one.

    VKBatchRequest * batch = [[VKBatchRequest alloc] initWithRequests:request1, request2, nil];

3) Load the obtained request.

    [batch executeWithResultBlock:^(NSArray *responses) { 
            NSLog(@"Responses: %@", responses); 
        } errorBlock:^(VKError *error) { 
            NSLog(@"Error: %@", error); 
    }];
    
4) The result of each method returns to a corresponding completeBlock. The responses array contains responses of the requests in order they have been passed.

