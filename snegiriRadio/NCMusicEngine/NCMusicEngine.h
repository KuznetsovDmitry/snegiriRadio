//Copyright (c) 2013 Yanan Cheng aka. nickcheng
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.
//
//
//  NCMusicEngine.h
//  NCMusicEngine
//
//  Created by nickcheng on 12-12-2.
//  Copyright (c) 2012年 NC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNCMusicEngineCacheFolderName @"Kuznetsov-Dmitry.snegiriRadio"
#define kNCMusicEngineCheckMusicInterval 0.1f // Seconds
#define kNCMusicEngineSizeBuffer 100000.0f // Bytes
#define kNCMusicEnginePauseMargin 1.0f  // Seconds
#define kNCMusicEnginePlayMargin 5.0f // Seconds

@protocol NCMusicEngineDelegate;


typedef enum {
  NCMusicEnginePlayStateStopped,
  NCMusicEnginePlayStatePlaying,
  NCMusicEnginePlayStatePaused,
  NCMusicEnginePlayStateEnded,
  NCMusicEnginePlayStateError
} NCMusicEnginePlayState;

typedef enum {
  NCMusicEngineDownloadStateNotDownloaded,
  NCMusicEngineDownloadStateDownloading,
//  NCMusicEngineDownloadStatePartial,
  NCMusicEngineDownloadStateDownloaded,
  NCMusicEngineDownloadStateError
} NCMusicEngineDownloadState;


@interface NCMusicEngine : NSObject

@property (nonatomic, assign, readonly) NCMusicEnginePlayState playState;
@property (nonatomic, assign, readonly) NCMusicEngineDownloadState downloadState;
@property (nonatomic, assign, readonly) BOOL backgroundPlayingEnabled;
@property (nonatomic, strong, readonly) NSError *error;
@property (weak) id<NCMusicEngineDelegate> delegate;

- (id)initWithSetBackgroundPlaying:(BOOL)setBGPlay;
- (void)prepareBackgroundPlaying;
- (void)playUrl:(NSURL*)url;
- (void)playUrl:(NSURL *)url withCacheKey:(NSString *)cacheKey;
- (void)pause;
- (void)resume;
- (void)stop; // Stop music and stop download.
- (void)volume:(float)vol;

@end


@protocol NCMusicEngineDelegate <NSObject>

//- (NSURL*)engineExpectsNextUrl:(NCMusicEngine *)engine;

@optional
- (void)engine:(NCMusicEngine *)engine didChangePlayState:(NCMusicEnginePlayState)playState;
- (void)engine:(NCMusicEngine *)engine didChangeDownloadState:(NCMusicEngineDownloadState)downloadState;
- (void)engine:(NCMusicEngine *)engine downloadProgress:(CGFloat)progress;
- (void)engine:(NCMusicEngine *)engine playProgress:(CGFloat)progress;

@end
