//
//  VKRequest.m
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
#import "VKRequest.h"
#import "NSString+MD5.h"
#import "OrderedDictionary.h"
#import "VKAuthorizeController.h"
#import "VKHTTPClient.h"
#import "VKError.h"

#define SUPPORTED_LANGS_ARRAY @[@"ru", @"en", @"ua", @"es", @"fi", @"de", @"it"]

@interface VKRequest ()
@property (readwrite, assign) int attemptsUsed;
@end

@implementation VKRequest
@synthesize methodName = _methodName,
methodParameters = _methodParameters,
httpMethod = _httpMethod,
preferredLang = _preferredLang,
attemptsUsed  = _attemptsUsed;
#pragma mark Init
+ (instancetype)requestWithMethod:(NSString *)method andParameters:(NSDictionary *)parameters andHttpMethod:(NSString *)httpMethod {
	VKRequest *newRequest = [VKRequest new];
	//Common parameters
	newRequest.parseModel         = YES;
    
	newRequest->_methodName       = method;
	newRequest->_methodParameters = parameters;
	newRequest->_httpMethod       = httpMethod;
    
	return newRequest;
}

+ (instancetype)requestWithMethod:(NSString *)method andParameters:(NSDictionary *)parameters andHttpMethod:(NSString *)httpMethod classOfModel:(Class)modelClass {
	VKRequest *request = [self requestWithMethod:method andParameters:parameters andHttpMethod:httpMethod];
	request->_modelClass = modelClass;
	return request;
}

+ (instancetype)photoRequestWithPostUrl:(NSString *)url withPhotos:(NSArray *)photoObjects;
{
	VKRequest *newRequest  = [VKRequest new];
	newRequest.attempts     = 0;
	newRequest->_httpMethod = @"POST";
	newRequest->_uploadUrl  = url;
	newRequest->_photoObjects = photoObjects;
	return newRequest;
}
- (id)init {
	self = [super init];
	self->_attemptsUsed     = 0;
	//If system language is not supported, we use english
	self.preferredLang      = @"en";
    //By default there is 1 attempt for loading.
	self.attempts           = 1;
    //By default we use system language.
    self.useSystemLanguage  = YES;
    self.secure             = YES;
	return self;
}

- (NSString *)description {
//	return [NSString stringWithFormat:@"<VKRequest: %p>\nMethod: %@ (%@)\nparameters: %@", self, _methodName, _httpMethod, _methodParameters];
    return [NSString stringWithFormat:@"<VKRequest: %p; Method: %@ (%@)>", self, _methodName, _httpMethod];
}

#pragma mark Execution
- (void)executeWithResultBlock:(void (^)(VKResponse *))completeBlock
                    errorBlock:(void (^)(VKError *))errorBlock {
	self.completeBlock = completeBlock;
	self.errorBlock    = errorBlock;
    
	[self start];
}

- (void)executeAfter:(VKRequest *)request
     withResultBlock:(void (^)(VKResponse *response))completeBlock
          errorBlock:(void (^)(VKError *error))errorBlock {
	self.completeBlock = completeBlock;
	self.errorBlock    = errorBlock;
	[request addPostRequest:self];
}

- (void)addPostRequest:(VKRequest *)postRequest {
	if (!_postRequestsQueue)
		_postRequestsQueue = [NSMutableArray new];
	[_postRequestsQueue addObject:postRequest];
}

- (NSURLRequest *)getPreparedRequest {
	//Add common parameters to parameters list
	if (!_preparedParameters && !_uploadUrl) {
		_preparedParameters = [[OrderedDictionary alloc] initWithCapacity:self.methodParameters.count * 2];
		for (NSString *key in self.methodParameters) {
			[_preparedParameters setObject:self.methodParameters[key] forKey:key];
		}
		VKAccessToken *token = [VKSdk getAccessToken];
		if (token == nil) {
			VKError *error = [VKError errorWithCode:VK_API_REQUEST_NOT_PREPARED];
			error.errorMessage = @"Access token is nil";
			[self provideError:error];
			return nil;
		}
		[_preparedParameters setObject:token.accessToken forKey:VK_API_ACCESS_TOKEN];
		if (!(self.secure || token.secret) || token.httpsRequired)
			self.secure = YES;
        
		//Set actual version of API
		[_preparedParameters setObject:VK_SDK_API_VERSION forKey:@"v"];
		//Set preferred language for request
		[_preparedParameters setObject:self.preferredLang forKey:VK_API_LANG];
		//Set current access token from SDK object
        
		if (self.secure) {
			//If request is secure, we need all urls as https
			[_preparedParameters setObject:@"1" forKey:@"https"];
		}
		if (token.secret) {
			//If it not, generate signature of request
			NSString *sig = [self generateSig:_preparedParameters token:token];
			[_preparedParameters setObject:sig forKey:VK_API_SIG];
		}
		//From that moment you cannot modify parameters.
		//Specially for http loading
	}
    
	NSMutableURLRequest *request = nil;
	if (!_uploadUrl) {
		request = [[VKHTTPClient getClient] requestWithMethod:self.httpMethod path:self.methodName parameters:_preparedParameters secure:self.secure];
	}
	else {
		request = [[VKHTTPClient getClient] multipartFormRequestWithMethod:@"POST" path:_uploadUrl images:_photoObjects];
	}
    
	[request setValue:nil forHTTPHeaderField:@"Accept-Language"];
	return request;
}
- (NSOperation*) executionOperation
{
    VKHTTPOperation * operation = [VKHTTPOperation operationWithRequest:self];
	if (!operation)
		return nil;
	[operation setCompletionBlockWithSuccess: ^(VKHTTPOperation *operation, id JSON) {
	    if ([JSON objectForKey:@"error"]) {
	        VKError *error = [VKError errorWithJson:[JSON objectForKey:@"error"]];
	        if ([self processCommonError:error]) return;
	        [self provideError:error];
	        return;
		}
	    [self provideResponse:JSON];
	} failure: ^(VKHTTPOperation *operation, NSError *error) {
#ifdef DEBUG
	    if (operation.response.statusCode == 200) {
	        [self provideResponse:operation.responseJson];
	        return;
		}
#endif
	    if (self.attempts == 0 || ++self.attemptsUsed < self.attempts) {
	        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^(void) {
	            [self start];
			});
	        return;
		}
        
	    VKError *vkErr = [VKError errorWithCode:operation.response.statusCode];
	    vkErr.httpError = error;
	    [self provideError:vkErr];
	}];
	[self setupProgress:operation];
    return operation;
}
- (void)start {
	_executionOperation = self.executionOperation;
    if (_executionOperation == nil)
        return;
	[[VKHTTPClient getClient] enqueueOperation:_executionOperation];
}

- (void)provideResponse:(id)JSON {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
	    VKResponse *vkResp = [VKResponse new];
	    vkResp.request      = self;
	    if (JSON[@"response"]) {
	        vkResp.json = JSON[@"response"];
            
	        if (self.parseModel && _modelClass) {
	            id object = [_modelClass alloc];
	            if ([object respondsToSelector:@selector(initWithDictionary:)]) {
	                vkResp.parsedModel = [object initWithDictionary:JSON];
				}
			}
		}
	    else
			vkResp.json = JSON;
        
	    for (VKRequest *postRequest in _postRequestsQueue)
			[postRequest start];
	    dispatch_sync(dispatch_get_main_queue(), ^{
	        if (self.completeBlock)
				self.completeBlock(vkResp);
		});
	});
}

- (void)provideError:(VKError *)error {
	error.request = self;
	if (self.errorBlock) {
		self.errorBlock(error);
	}
	for (VKRequest *postRequest in _postRequestsQueue)
		if (postRequest.errorBlock) postRequest.errorBlock(error);
}

- (void)repeat {
	_attemptsUsed = 0;
	_preparedParameters = nil;
	[self start];
}

- (void)cancel {
	[_executionOperation cancel];
	[self provideError:[VKError errorWithCode:VK_API_CANCELED]];
}

- (void)setupProgress:(VKHTTPOperation *)operation {
	if (self.progressBlock) {
		[operation setUploadProgressBlock: ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             self.progressBlock(VKProgressTypeUpload, totalBytesWritten, totalBytesExpectedToWrite);
         }];
		[operation setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             self.progressBlock(VKProgressTypeDownload, totalBytesRead, totalBytesExpectedToRead);
         }];
	}
}

- (void)addExtraParameters:(NSDictionary *)extraParameters {
	if (!_methodParameters)
		_methodParameters = [extraParameters mutableCopy];
	else {
		NSMutableDictionary *params = [_methodParameters mutableCopy];
		[params addEntriesFromDictionary:extraParameters];
		_methodParameters = params;
	}
}

#pragma mark Sevice
- (NSString *)generateSig:(OrderedDictionary *)params token:(VKAccessToken *)token {
	//Read description here https://vk.com/dev/api_nohttps
	//First of all, we need key-value pairs in order of request
	NSMutableArray *paramsArray = [NSMutableArray arrayWithCapacity:params.count];
	for (NSString *key in params) {
		[paramsArray addObject:[key stringByAppendingFormat:@"=%@", params[key]]];
	}
	//Then we generate "request string" /method/{METHOD_NAME}?{GET_PARAMS}{POST_PARAMS}
	NSString *requestString = [NSString stringWithFormat:@"/method/%@?%@", _methodName, [paramsArray componentsJoinedByString:@"&"]];
	requestString = [requestString stringByAppendingString:token.secret];
	NSLog(@"%@", requestString);
	return [requestString MD5];
}

- (BOOL)processCommonError:(VKError *)error {
	if (error.errorCode == VK_API_ERROR) {
		if (error.apiError.errorCode == 14) {
			error.apiError.request = self;
			[[VKSdk instance].delegate vkSdkNeedCaptchaEnter:error.apiError];
			return YES;
		}
		else if (error.apiError.errorCode == 16) {
			VKAccessToken *token = [VKSdk getAccessToken];
			token.httpsRequired = YES;
			[self repeat];
			return YES;
		}
		else if (error.apiError.errorCode == 17) {
			[VKAuthorizeController presentForValidation:error.apiError];
			return YES;
		}
	}
    
	return NO;
}

#pragma mark Properties
- (NSString *)preferredLang {
	NSString *lang = _preferredLang;
	if (self.useSystemLanguage) {
		lang = [NSLocale preferredLanguages][0];
		if ([lang isEqualToString:@"uk"])
			lang = @"ua";
		if (![SUPPORTED_LANGS_ARRAY containsObject:lang])
			lang = _preferredLang;
	}
	return lang;
}

- (void)setPreferredLang:(NSString *)preferredLang {
	_preferredLang = preferredLang;
	self.useSystemLanguage = NO;
}

@end
