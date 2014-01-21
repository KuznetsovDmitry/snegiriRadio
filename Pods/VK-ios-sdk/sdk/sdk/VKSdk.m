//
//  sdk.m
//
//  Copyright (c) 2013 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "VKSdk.h"
#import "VKAuthorizeController.h"
@implementation VKSdk
@synthesize delegate = _delegate;
static VKSdk *vkSdkInstance = nil;
#pragma mark Initialization
+ (void)initialize {
	NSAssert([VKSdk class] == self, @"Subclassing is not welcome");
	vkSdkInstance = [[super alloc] initUniqueInstance];
}

+ (instancetype)instance {
	if (!vkSdkInstance) {
		[NSException raise:@"VKSdk should be initialized" format:@"Use [VKSdk initialize:delegate] method"];
	}
	return vkSdkInstance;
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate andAppId:(NSString *)appId {
	[self initializeWithDelegate:delegate andAppId:appId andCustomToken:nil];
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate andAppId:(NSString *)appId andCustomToken:(VKAccessToken *)token {
	vkSdkInstance->_delegate            = delegate;
	vkSdkInstance->_currentAppId        = appId;
    
	if (token) {
		vkSdkInstance->_accessToken     = token;
		if ([delegate respondsToSelector:@selector(vkSdkDidAcceptUserToken:)]) {
			[delegate vkSdkDidAcceptUserToken:token];
		}
	}
}

- (instancetype)initUniqueInstance {
	return [super init];
}

#pragma mark Authorization
+ (void)authorize:(NSArray *)permissions {
	[self authorize:permissions revokeAccess:NO];
}

+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess {
	[self authorize:permissions revokeAccess:revokeAccess forceOAuth:NO];
}

+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth {
	NSString *clientId = vkSdkInstance->_currentAppId;
	NSURL *urlToOpen = [NSURL URLWithString:
	                    [NSString stringWithFormat:@"vkauth://authorize?client_id=%@&scope=%@&revoke=%d",
	                     clientId,
	                     [permissions componentsJoinedByString:@","], revokeAccess ? 1:0]];
	if (!forceOAuth && [[UIApplication sharedApplication] canOpenURL:urlToOpen])
		[[UIApplication sharedApplication] openURL:urlToOpen];
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:
		                                            [VKAuthorizeController buildAuthorizationUrl:[NSString stringWithFormat:@"vk%@://authorize", clientId]
		                                                                                clientId:clientId
		                                                                                   scope:[permissions componentsJoinedByString:@","]
		                                                                                  revoke:revokeAccess
		                                                                                 display:@"mobile"]]];
    //    Authorization through popup webview
    //        [VKAuthorizeController presentForAuthorizeWithAppId:vkSdkInstance->_currentAppId
    //                                             andPermissions:permissions
    //                                               revokeAccess:revokeAccess];
}

#pragma mark Access token
+ (void)setAccessToken:(VKAccessToken *)token {
	vkSdkInstance->_accessToken = token;
	if ([vkSdkInstance->_delegate respondsToSelector:@selector(vkSdkDidReceiveNewToken:)])
		[vkSdkInstance->_delegate vkSdkDidReceiveNewToken:token];
}

+ (void)setAccessTokenError:(VKError *)error {
	vkSdkInstance->_accessToken = nil;
	[vkSdkInstance->_delegate vkSdkUserDeniedAccess:error];
}

+ (VKAccessToken *)getAccessToken {
	return vkSdkInstance->_accessToken;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl {
	NSString *urlString = [passedUrl absoluteString];
	NSString *parametersString = [urlString substringFromIndex:[urlString rangeOfString:@"#"].location + 1];
	if (parametersString.length == 0) {
		VKError *error = [VKError errorWithCode:VK_API_CANCELED];
		[VKSdk setAccessTokenError:error];
		return NO;
	}
	NSDictionary *parametersDict = [VKUtil explodeQueryString:parametersString];
    
	if (parametersDict[@"error"] || parametersDict[@"fail"]) {
		VKError *error     = [VKError errorWithQuery:parametersDict];
		[VKSdk setAccessTokenError:error];
		return NO;
	}
	else if (parametersDict[@"success"]) {
		VKAccessToken *token = [VKSdk getAccessToken];
		token.accessToken   = parametersDict[@"access_token"];
		token.secret        = parametersDict[@"secret"];
		token.userId        = parametersDict[@"user_id"];
	}
	else {
		VKAccessToken *token = [VKAccessToken tokenFromUrlString:parametersString];
		[VKSdk setAccessToken:token];
	}
	return YES;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication {
	if ([sourceApplication isEqualToString:@"com.vk.odnoletkov.client"] ||
	    [sourceApplication isEqualToString:@"com.vk.client"] ||
	    [sourceApplication isEqualToString:@"com.apple.mobilesafari"])
		return [self processOpenURL:passedUrl];
	return NO;
}

@end
