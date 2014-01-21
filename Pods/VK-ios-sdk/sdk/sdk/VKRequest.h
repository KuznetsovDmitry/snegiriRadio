//
//  VKRequest.h
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

#import <Foundation/Foundation.h>
#import "VKResponse.h"
#import "VKApiConst.h"
#import "VKObject.h"
#import "OrderedDictionary.h"
#import "VKHTTPOperation.h"

@class VKError;

/**
 Class for execution API-requests
 */
@interface VKRequest : VKObject
{
@protected
    /// Working operation for this request
	NSOperation *_executionOperation;
@private
	/// Selected method name
	NSString *_methodName;
	/// HTTP method for loading
	NSString *_httpMethod;
	/// Passed parameters for method
	NSDictionary *_methodParameters;
	/// Method parametes with common parameters
	OrderedDictionary *_preparedParameters;
	/// How much times request was loaded
	int _attemptsUsed;
	/// Url for uploading files
	NSString *_uploadUrl;
	/// Requests that should be called after current request.
	NSMutableArray *_postRequestsQueue;
	/// Class for model parsing
	Class _modelClass;
	/// Paths to photos
	NSArray *_photoObjects;
}
/// Specify language for API request
@property (nonatomic, strong) NSString *preferredLang;
/// Specify progress for uploading or downloading. Useless for text requests (because gzip encoding bytesTotal will always return -1)

@property (nonatomic, copy)   void (^progressBlock)(VKProgressType progressType, long long bytesLoaded, long long bytesTotal);
/// Specify completion block for request
@property (nonatomic, copy)   void (^completeBlock)(VKResponse *response);
/// Specity error (HTTP or API) block for request.
@property (nonatomic, copy)   void (^errorBlock)(VKError *error);
/// Specify attempts for request loading if caused HTTP-error. 0 for infinite
@property (nonatomic, assign) int attempts;
/// Use HTTPS requests (by default is YES). If http-request is impossible (user denied no https access), SDK will load https version
@property (nonatomic, assign) BOOL secure;
/// Sets current system language as default for API data
@property (nonatomic, assign) BOOL useSystemLanguage;
/// Set to false if you don't need automatic model parsing
@property (nonatomic, assign) BOOL parseModel;
/// Returns method for current request, e.g. users.get
@property (nonatomic, readonly) NSString *methodName;
/// Returns HTTP-method for current request
@property (nonatomic, readonly) NSString *httpMethod;
/// Returns list of method parameters (without common parameters)
@property (nonatomic, readonly) NSDictionary *methodParameters;
/// Returns http operation that can be enqueued
@property (nonatomic, readonly) NSOperation *executionOperation;

///-------------------------------
/// @name Preparing requests
///-------------------------------
/**
 Creates new request with parameters. See documentation for methods here https://vk.com/dev/methods
 @param method API-method name, e.g. audio.get
 @param parameters method parameters
 @param httpMethod HTTP method for execution, e.g. GET, POST
 @return Complete request object for execute or configure method
 */
+ (instancetype)requestWithMethod:(NSString *)method
                    andParameters:(NSDictionary *)parameters
                    andHttpMethod:(NSString *)httpMethod;

/**
 Creates new request with parameters. See documentation for methods here https://vk.com/dev/methods
 @param method API-method name, e.g. audio.get
 @param parameters method parameters
 @param httpMethod HTTP method for execution, e.g. GET, POST
 @param modelClass class for automatic parse
 @return Complete request object for execute or configure method
 */
+ (instancetype)requestWithMethod:(NSString *)method
                    andParameters:(NSDictionary *)parameters
                    andHttpMethod:(NSString *)httpMethod
                     classOfModel:(Class)modelClass;

/**
 Creates new request for upload image to url
 @param url url for upload, which was received from special methods
 @param photoObjects VKPhoto object describes photos
 @return Complete request object for execute
 */
+ (instancetype)photoRequestWithPostUrl:(NSString *)url
                             withPhotos:(NSArray *)photoObjects;

/**
 Prepares NSURLRequest and returns prepared url request for current vkrequest
 @return Prepared request used for loading
 */
- (NSURLRequest *)getPreparedRequest;

///-------------------------------
/// @name Execution
///-------------------------------
/**
 Executes that request, and returns result to blocks
 @param completeBlock called if there were no HTTP or API errors, returns execution result.
 @param errorBlock called immediately if there was API error, or after <b>attempts</b> tries if there was an HTTP error
 */
- (void)executeWithResultBlock:(void (^)(VKResponse *response))completeBlock
                    errorBlock:(void (^)(VKError *error))errorBlock;
/**
 Register current request for execute after passed request, if passed request is successful. If it's not, errorBlock will be called.
 @param request after which request must be called that request
 @param completeBlock called if there were no HTTP or API errors, returns execution result.
 @param errorBlock called immediately if there was API error, or after <b>attempts</b> tries if there was an HTTP error
 */
- (void)executeAfter:(VKRequest *)request
     withResultBlock:(void (^)(VKResponse *response))completeBlock
          errorBlock:(void (^)(VKError *error))errorBlock;

/**
 Starts loading of prepared request. You can use it instead of executeWithResultBlock
 */
- (void)start;
/**
 Repeats this request with initial parameters and blocks.
 Used attempts will be set to 0.
 */
- (void)repeat;
/**
 Cancel current request. Result will be not passed. errorBlock will be called with error code
 */
- (void)cancel;

///-------------------------------
/// @name Operating with parameters
///-------------------------------
/**
 Adds additional parameters to that request
 @param extraParameters parameters supposed to be added
 */
- (void)addExtraParameters:(NSDictionary *)extraParameters;

@end
