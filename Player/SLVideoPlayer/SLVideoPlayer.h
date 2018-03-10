//
//  SLVideoPlayer.h
//  SLVideoPlayer
//
//  Created by sleen on 2017/5/8.
//  Copyright © 2017年 fireplain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLVideoPlayerToolBar.h"
@import AVFoundation;

typedef void (^SLVideoPlayerPostBarragesAction)(UIImage *image, CGFloat seconds);
typedef void (^SLVideoPlayerPlayHandler)(BOOL playing);
typedef void (^SLVideoPlayerShareBlock)(void);
typedef void (^SLVideoPlayerFinishBlock)(void);

typedef void(^SLVideoPlayerCurrentIm)(UIImage *image);
typedef NS_ENUM(NSUInteger, SLVideoViewShowType) {
    SLVideoViewShowTypeNormal,      // 正常
    SLVideoViewShowTypeHorizontal,  // 竖屏
    SLVideoViewShowTypeVertical     // 横屏
};


@interface SLVideoPlayer : UIView

/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;
/** 播放器Item */
@property (nonatomic, strong) AVPlayerItem *playerItem;

/** 底部工具栏 */
@property (nonatomic, strong) SLVideoPlayerToolBar *toolBarView;
@property (nonatomic, strong) UILabel *barrageLabel;

@property (nonatomic, strong) UIView *topNavView;
@property (nonatomic, strong) UIButton *navBackView;
@property (nonatomic, strong) UIButton *navBarrageView;
@property (nonatomic, strong) UIButton *navShareView;

/** 视频的Url */
@property (nonatomic, copy) NSString *videoStr;
/** 播放暂停按钮 */
@property (nonatomic, strong) UIButton *playOrPauseButton;

@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, assign) SLVideoViewShowType showType;

- (void)updateWidgetsShow;
- (void)playVideoWithStr:(NSString *)videoStr;
- (void)playVideoWithStr:(NSString *)videoStr needAutoPlay:(BOOL)autoPlay;
- (void)clearAllTimeObserver;
- (void)pauseVideo;

@property (nonatomic, assign) CGRect normalFrame;
@property (nonatomic, weak) UIView *normalParentView;


@property (nonatomic, copy) SLVideoPlayerPostBarragesAction action;
- (void)setPostBarrageAction:(SLVideoPlayerPostBarragesAction)action;
- (UIImage *)getCurrentImage;
@property (nonatomic, copy) SLVideoPlayerPlayHandler playHandler;
- (void)showBarragesWithDict:(NSDictionary *)dict;


@property (nonatomic, assign) UIStatusBarStyle oldStyle;

@property (nonatomic, copy) SLVideoPlayerShareBlock shareBlock;
@property (nonatomic, copy) SLVideoPlayerFinishBlock finishBlock;
@end

@interface SLVideoPlayerManager : NSObject
@property (nonatomic, weak) SLVideoPlayer *currentPlayer;
+ (SLVideoPlayerManager *)shareManager;
@end
