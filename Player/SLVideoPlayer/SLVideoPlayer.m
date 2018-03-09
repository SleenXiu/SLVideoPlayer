//
//  SLVideoPlayer.m
//  SLVideoPlayer
//
//  Created by sleen on 2017/5/8.
//  Copyright © 2017年 fireplain. All rights reserved.
//

#import "SLVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "SLVideoPlayerUtil.h"

@interface SLVideoPlayer () <SLVideoPlayerToolBarDelegate>{
    id _playTimeObserver; // 观察者
    BOOL _isSliding;
    BOOL _isPlaying;
    AVPlayerLayer *_playLayer;
    BOOL _fullHiden;
    
    AVPlayerItemVideoOutput *_videoOutPut;
}
@property (nonatomic, strong) NSTimer *time;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSDictionary *dict;
@end
@implementation SLVideoPlayer
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playLayer = (AVPlayerLayer *)self.layer;
        self.showType = SLVideoViewShowTypeNormal;
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        [self initWidgets];
    }
    return self;
}
- (void)initWidgets {
    
    [_playLayer setPlayer:self.player];
    
    _videoOutPut = [[AVPlayerItemVideoOutput alloc] init];
    
    [self addSubview:self.playOrPauseButton];
    
    [self addSubview:self.replayButton];
    
    [self addSubview:self.shareButton];
    
    [self addSubview:self.toolBarView];
    
    [self addSubview:_indicatorView];
    [self updateWidgetsShow];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
}
- (void)fullScreenButtonClick:(UIButton *)fullBtn {
    if (!self.fullScreenBlock) {
        return;
    }
    fullBtn.selected = !fullBtn.selected;
    NSLog(@"%f", _playerItem.presentationSize.width);
    if (_playerItem.presentationSize.width > _playerItem.presentationSize.height) {
        _showType = SLVideoViewShowTypeHorizontal;
    } else {
        _showType = SLVideoViewShowTypeVertical;
    }
    
    if (_fullScreenBlock) {
        _fullScreenBlock(fullBtn);
    }
    self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
}
- (void)addFullScreenBlock:(fullScreenClickBlock)block {
    _fullScreenBlock = block;
}
- (void)updateWidgetsShow {
    CGFloat playerW = self.frame.size.width;
    CGFloat playerH = self.frame.size.height;
    
    if (_showType == SLVideoViewShowTypeNormal) {
        
        self.playOrPauseButton.frame = CGRectMake((playerW-72)/2, (playerH-72)/2, 72, 72);
        [self.playOrPauseButton setBackgroundImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"play_normal"] forState:UIControlStateNormal];
        [self.playOrPauseButton setBackgroundImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"pause_normal"] forState:UIControlStateSelected];
        
        
        CGFloat toolViewH = 29;
        
        self.toolBarView.frame = CGRectMake(0, playerH-toolViewH, playerW, toolViewH);
        [self.toolBarView setNeedsUpdateConstraints];
        
        
        _indicatorView.center = CGPointMake((playerW)/2, (playerH)/2);
        
        if (_fullHiden) {
            _allTimeLabel.frame = CGRectMake(playerW - 46, (toolViewH-17)/2, 46, 17);
            
            _bufferProgress.frame = CGRectMake(46, (toolViewH-2)/2, playerW  - 46*2, 2);
            _progressSlider.frame = CGRectMake(46-4, (toolViewH-8)/2, playerW  - 46*2+8, 8);
        }
        
    } else if (_showType == SLVideoViewShowTypeHorizontal) {
        
        self.playOrPauseButton.frame = CGRectMake((playerH-100)/2, (playerW-100)/2, 100, 100);
        
        CGFloat toolViewH = 55;
        self.toolBarView.frame = CGRectMake(0, playerW-toolViewH, playerH, toolViewH);
        
        _indicatorView.center = CGPointMake((playerH)/2, (playerW)/2);
    } else {
        
        self.playOrPauseButton.frame = CGRectMake((playerW-100)/2, (playerH-100)/2, 100, 100);
        
        CGFloat toolViewH = 55;
        self.toolBarView.frame = CGRectMake(0, playerH-toolViewH, playerH, toolViewH);
        _indicatorView.center = CGPointMake((playerW)/2, (playerH)/2);
    }
}
- (void)hideFullScreenButton {
    self.fullScreenButton.hidden = YES;
    
    _fullHiden = YES;
}
#pragma mark - public
- (void)playVideoWithStr:(NSString *)videoStr needAutoPlay:(BOOL)autoPlay {
    if (videoStr.length <= 0) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        return;
    }
    
    
    NSURL *url = [NSURL URLWithString:videoStr];
    
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    
    [_playerItem addOutput:_videoOutPut];
    
    if (autoPlay) {
        [self.player play];
        self.playOrPauseButton.selected = YES;
        self.playOrPauseButton.hidden = YES;
        _isPlaying = YES;
    }
    
    self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
   
    [self addObservers];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
}
- (void)playVideoWithStr:(NSString *)videoStr {
    [self playVideoWithStr:videoStr needAutoPlay:NO];
}
#pragma mark - event
- (void)playOrPauseButtonClick:(UIButton *)playBtn {
    playBtn.selected = !playBtn.selected;
    SLVideoPlayerManager *shareManager = [SLVideoPlayerManager shareManager];
    if (playBtn.selected) {
        [self.player play];
        _isPlaying = YES;
        
        _toolView.hidden = YES;
        _playOrPauseButton.hidden = YES;
        self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    
        if (shareManager.currentPlayer) {
            [shareManager.currentPlayer pauseVideo];
        }
        shareManager.currentPlayer = self;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        });
    } else {
        [self.player pause];
        _isPlaying = NO;
        [self.time setFireDate:[NSDate distantFuture]];
        [self.indicatorView stopAnimating];
        shareManager.currentPlayer = nil;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        });
    }
}
- (void)replayButtonClick:(UIButton *)button {
    [self playOrPauseButtonClick:_playOrPauseButton];
    _replayButton.hidden = YES;
    _shareButton.hidden = YES;
}
- (void)shareButtonClick:(UIButton *)button {
    if (self.shareBlock) {
        self.shareBlock();
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isPlaying) {
        if (!self.playOrPauseButton.hidden) {
            self.toolBarView.hidden = YES;
            self.playOrPauseButton.hidden = YES;
        } else {
            self.toolBarView.hidden = NO;
            self.playOrPauseButton.hidden = NO;
            self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
        }
    }
}

#pragma mark - SLVideoPlayerToolBarDelegate
- (void)barPlayerSliderTouchUpInside {
    _isPlaying = NO;
    [self.player play];
}
- (void)barProgressSliderTouchDown {
    [self.player pause];
}
- (void)barPlayerSliderValueChanged:(UISlider *)progressSlider {
    _isSliding = YES;
    [self.player pause];
    
    // 跳转到拖拽秒处
    CMTime changedTime = CMTimeMakeWithSeconds(progressSlider.value, 1.0);
    [_playerItem seekToTime:changedTime completionHandler:^(BOOL finished) {
        if (finished) { // 跳转完成后做某事
            [self.player play];
            self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
            _isSliding = NO;
        }
    }];
}

#pragma mark - dealloc
- (void)dealloc {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.playerItem = nil;
    self.player = nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
#pragma mark - obserce
- (void)addObservers {
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObserverForPlayProgress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)playFinished:(NSNotification *)notification {
    self.playOrPauseButton.selected = NO;
    //    [_playerItem seekToTime:kCMTimeZero];
    
    [_playerItem seekToTime:kCMTimeZero completionHandler:nil];
    
    _isPlaying = NO;
    self.toolBarView.hidden = NO;
    _playOrPauseButton.hidden = YES;
    [self.time setFireDate:[NSDate distantFuture]];
    [SLVideoPlayerManager shareManager].currentPlayer = nil;
    
    _shareButton.hidden = NO;
    _replayButton.hidden = NO;
    if (self.finishBlock) {
        self.finishBlock();
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        if (status == AVPlayerStatusReadyToPlay) {
            // 播放进度总长
            self.toolBarView.progressSlider.maximumValue = CMTimeGetSeconds(playerItem.duration);
            // 设置总视频时间
            self.toolBarView.allTimeLabel.text = [SLVideoPlayerUtil sl_formatVideoTime:[NSString stringWithFormat:@"%zd", (int)CMTimeGetSeconds(playerItem.duration)]];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        if (_isPlaying) {
            
            // 总大小
            CGFloat totalDuration = CMTimeGetSeconds(playerItem.duration);
            // 获取item的缓冲数组
            NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval timeInterval = startSeconds + durationSeconds;
            [self.toolBarView.bufferProgress setProgress:timeInterval / totalDuration animated:YES];
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
        if (_isPlaying) {
            [_indicatorView startAnimating];
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        if (_isPlaying) {
            [self.player play];
        }
        
        [_indicatorView stopAnimating];
    }
}
#pragma mark - 播放进度
- (void)addObserverForPlayProgress {
    __weak SLVideoPlayer *weakSelf = self;
    
    // 播放进度, 每秒执行30次， CMTime 为30分之一秒
    _playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前播放秒
        CGFloat currentPlayTime = (double)weakSelf.playerItem.currentTime.value/ weakSelf.playerItem.currentTime.timescale;
        if (_isSliding == NO) {
            weakSelf.toolBarView.progressSlider.value = currentPlayTime;
            weakSelf.toolBarView.currentTimeLabel.text = [SLVideoPlayerUtil sl_formatVideoTime:[NSString stringWithFormat:@"%zd", (int)currentPlayTime]];
        }
//        NSLog(@"%.2f", CMTimeGetSeconds(weakSelf.playerItem.currentTime));
        NSString *key = [NSString stringWithFormat:@"%.2f", CMTimeGetSeconds(weakSelf.playerItem.currentTime)];
        if ([weakSelf.dict.allKeys containsObject:key]) {
            NSLog(@"%@", [weakSelf.dict valueForKey:key]);
        }
    }];
}
#pragma mark - getter
- (AVPlayer *)player {
    if (!_player) {
       _player = [[AVPlayer alloc] init];
    }
    return _player;
}
- (UIButton *)playOrPauseButton {
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playOrPauseButton setBackgroundImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"play_hor"] forState:UIControlStateNormal];
        [_playOrPauseButton setBackgroundImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"pause_hor"] forState:UIControlStateSelected];
    }
    return _playOrPauseButton;
}
- (UIButton *)replayButton {
    if (!_replayButton) {
        _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replayButton addTarget:self action:@selector(replayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _replayButton.hidden = YES;
    }
    return _replayButton;
}
- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _shareButton.hidden = YES;
    }
    return _shareButton;
}

- (SLVideoPlayerToolBar *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [[SLVideoPlayerToolBar alloc] init];
        _toolBarView.delegate = self;
    }
    return _toolBarView;
}
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _indicatorView.hidesWhenStopped = YES;
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}

- (void)hideToolViewAndPlayButton {
    if (_isPlaying) {
        //在这里执行事件
        _toolView.hidden = YES;
        _playOrPauseButton.hidden = YES;
    }
}
- (NSTimer *)time {
    if (!_time) {
        _time = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(hideToolViewAndPlayButton) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_time forMode:NSDefaultRunLoopMode];
    }
    return _time;
}
- (void)clearAllTimeObserver {
    [_player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    
    [self.time invalidate];
    self.time = nil;
}
- (void)pauseVideo {
    [self.player pause];
    _isPlaying = NO;
    
    _toolView.hidden = NO;
    _playOrPauseButton.hidden = NO;
    [self.time setFireDate:[NSDate distantFuture]];
    
    [SLVideoPlayerManager shareManager].currentPlayer = nil;
    [self.indicatorView stopAnimating];
    
    self.playOrPauseButton.selected = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
}
- (void)playVideo {
    [self.player play];
    _isPlaying = YES;
    
    _toolView.hidden = YES;
    _playOrPauseButton.hidden = YES;
    self.playOrPauseButton.selected = YES;
    self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    
    if ([SLVideoPlayerManager shareManager].currentPlayer) {
        [[SLVideoPlayerManager shareManager].currentPlayer pauseVideo];
    }
    [SLVideoPlayerManager shareManager].currentPlayer = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
}
- (void)postBarrageClick {
    
    if (self.action) {
        [self fullScreenButtonClick:_fullScreenButton];
        [self pauseVideo];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            UIImage *im = [UIImage new];
            self.action([self getCurrentImage], CMTimeGetSeconds(_playerItem.currentTime));
        });
        
    }
}
- (void)setPostBarrageAction:(SLVideoPlayerPostBarragesAction)action {
    self.action = action;
}

- (UIImage *)getCurrentImage {
    AVURLAsset *asset = (AVURLAsset *)_playerItem.asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:_playerItem.currentTime
                                              actualTime:NULL
                                                   error:NULL];
    UIImage *videoImage = [UIImage imageWithCGImage:thumb];
    CGImageRelease(thumb);
    return videoImage;
}
- (void)showBarragesWithDict:(NSDictionary *)dict {
    self.dict = dict;
}
@end

@implementation SLVideoPlayerManager

static SLVideoPlayerManager *_manager;
+ (SLVideoPlayerManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SLVideoPlayerManager alloc] init];
    });
    return _manager;
}
@end
