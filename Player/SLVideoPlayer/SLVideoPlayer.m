//
//  SLVideoPlayer.m
//  SLVideoPlayer
//
//  Created by sleen on 2017/5/8.
//  Copyright © 2017年 fireplain. All rights reserved.
//

#import "SLVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

#define SLColorRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface SLVideoPlayer ()
{
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
        [self initWidgets];
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        
    }
    return self;
}
- (void)initWidgets {
//    MDrawView *drawView = [[MDrawView alloc] initWithFrame:CGRectMake(0, 0, 375, 200)];
//    drawView.backgroundColor = [UIColor clearColor];
//    [self addSubview:drawView];
//    self.drawView = drawView;
    
    _player = [[AVPlayer alloc] init];
    [_playLayer setPlayer:_player];
    
    _videoOutPut = [[AVPlayerItemVideoOutput alloc] init];
    
    _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playOrPauseButton addTarget:self action:@selector(playOrPauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _playOrPauseButton.hidden = YES;
    [self addSubview:_playOrPauseButton];
    
//    @property (nonatomic, strong) UIButton *replayButton;
//    @property (nonatomic, strong) UIButton *shareButton;
    _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _replayButton.hidden = YES;
    [_replayButton addTarget:self action:@selector(replayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_replayButton];
    
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton.hidden = YES;
    [_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareButton];
    
    
    _toolView = [[UIView alloc] init];
    _toolView.backgroundColor = SLColorRGBA(0, 0, 0, 0.6);
    [self addSubview:_toolView];
    
//    _barrageLabel = [[UILabel alloc] init];
//    _barrageLabel.text = @"弹幕";
//    _barrageLabel.textAlignment = NSTextAlignmentCenter;
//    _barrageLabel.font = kEasyFont(12);
//    _barrageLabel.textColor = [UIColor whiteColor];
//    [_toolView addSubview:_barrageLabel];
//
//    _barrageSwitch = [[SLSwitch alloc] init];
//    _barrageSwitch.bgActiveColor = HY_RGB(48, 138, 242);
//    _barrageSwitch.opened = YES;
//    [_toolView addSubview:_barrageSwitch];
    
    _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenButton setImage:[self sl_getImageFromBundle:@"full_screen_nor"] forState:UIControlStateNormal];
    [_fullScreenButton setImage:[self sl_getImageFromBundle:@"full_screen_sel"] forState:UIControlStateSelected];
    [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:_fullScreenButton];
    
    _currentTimeLabel = [[UILabel alloc] init];
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    [_toolView addSubview:_currentTimeLabel];
    
    _allTimeLabel = [[UILabel alloc] init];
    _allTimeLabel.textColor = [UIColor whiteColor];
    _allTimeLabel.textAlignment = NSTextAlignmentCenter;
    _allTimeLabel.text = @"00:00";
    [_toolView addSubview:_allTimeLabel];
    
    _bufferProgress = [[UIProgressView alloc] init];
    _bufferProgress.progressViewStyle = UIProgressViewStyleDefault;
    _bufferProgress.progressTintColor = SLColorRGBA(204, 204, 204, 1.0);
    _bufferProgress.trackTintColor = SLColorRGBA(136, 136, 136, 1.0);
    for (UIImageView * imageview in _bufferProgress.subviews) {
        imageview.layer.cornerRadius = 1;
        imageview.clipsToBounds = YES;
    }
    [_toolView addSubview:_bufferProgress];
    
    _progressSlider = [[UISlider alloc] init];
    _progressSlider.backgroundColor = [UIColor clearColor];
    //    [_progressSlider setThumbImage:[UIImage imageWithNoCacheName:@"slider"] forState:UIControlStateNormal];
    [_progressSlider setMinimumTrackTintColor:SLColorRGBA(255, 255, 255, 1.0)];
    [_progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [_progressSlider addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider addTarget:self action:@selector(playerSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_progressSlider addTarget:self action:@selector(playerSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [_toolView addSubview:_progressSlider];
    
    
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView startAnimating];
    [self addSubview:_indicatorView];
    
    
//    _topNavView = [[UIView alloc] init];
//    _topNavView.backgroundColor = SLColorRGBA(0, 0, 0, 0.6);
//    [self addSubview:_topNavView];
//
//    _navBarrageView = [[UIButton alloc] init];
//    [_navBarrageView setTitle:@"弹幕" forState:UIControlStateNormal];
//    _navBarrageView.frame = CGRectMake(10, 20, 46, 30);
//    [_navBarrageView addTarget:self action:@selector(postBarrageClick) forControlEvents:UIControlEventTouchUpInside];
//    [_topNavView addSubview:_navBarrageView];
    
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
        
        _playOrPauseButton.frame = CGRectMake((playerW-72)/2, (playerH-72)/2, 72, 72);
        [_playOrPauseButton setBackgroundImage:[self sl_getImageFromBundle:@"play_normal"] forState:UIControlStateNormal];
        [_playOrPauseButton setBackgroundImage:[self sl_getImageFromBundle:@"pause_normal"] forState:UIControlStateSelected];
        
        _replayButton.frame = CGRectMake(playerW/2.0-72-16, (playerH-72)/2, 72, 72);
        [_replayButton setBackgroundImage:[self sl_getImageFromBundle:@"video_replay"] forState:UIControlStateNormal];
        
        _shareButton.frame = CGRectMake(playerW/2.0+16, (playerH-72)/2, 72, 72);
        [_shareButton setBackgroundImage:[self sl_getImageFromBundle:@"video_share"] forState:UIControlStateNormal];
        
//        _topNavView.hidden = YES;
        CGFloat toolViewH = 29;
        
        _toolView.frame = CGRectMake(0, playerH-toolViewH, playerW, toolViewH);
        _fullScreenButton.frame = CGRectMake(playerW-toolViewH, 0, toolViewH, toolViewH);
        
//        _barrageLabel.frame = CGRectMake(0, (toolViewH-12)/2, 42, 12);
//        _barrageLabel.font = [UIFont systemFontOfSize:12];
//        _barrageSwitch.frame = CGRectMake(40, (toolViewH-12)/2, 24, 12);
        
        _currentTimeLabel.frame = CGRectMake(70-70, (toolViewH-17)/2, 46, 17);
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _allTimeLabel.frame = CGRectMake(playerW - toolViewH - 46, (toolViewH-17)/2, 46, 17);
        _allTimeLabel.font = [UIFont systemFontOfSize:12];
        
        _bufferProgress.frame = CGRectMake(72+46-72, (toolViewH-2)/2, playerW - toolViewH - 46*2-72+72, 2);
        _progressSlider.frame = CGRectMake(72+46-4-72, (toolViewH-8)/2, playerW - toolViewH - 46*2+8-72+72, 8);
        [_progressSlider setThumbImage:[self sl_getImageFromBundle:@"silder_normal"] forState:UIControlStateNormal];
        
        _indicatorView.center = CGPointMake((playerW)/2, (playerH)/2);
        
        if (_fullHiden) {
            _allTimeLabel.frame = CGRectMake(playerW - 46, (toolViewH-17)/2, 46, 17);
            
            _bufferProgress.frame = CGRectMake(46, (toolViewH-2)/2, playerW  - 46*2, 2);
            _progressSlider.frame = CGRectMake(46-4, (toolViewH-8)/2, playerW  - 46*2+8, 8);
        }
        
    } else if (_showType == SLVideoViewShowTypeHorizontal) {
        
        _playOrPauseButton.frame = CGRectMake((playerH-100)/2, (playerW-100)/2, 100, 100);
        [_playOrPauseButton setBackgroundImage:[self sl_getImageFromBundle:@"play_hor"] forState:UIControlStateNormal];
        [_playOrPauseButton setBackgroundImage:[self sl_getImageFromBundle:@"pause_hor"] forState:UIControlStateSelected];
        
        _replayButton.frame = CGRectMake(playerH/2.0-100-16,(playerW-100)/2,  100, 100);
        [_replayButton setBackgroundImage:[self sl_getImageFromBundle:@"video_replay_hor"] forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(playerH/2.0+16,(playerW-100)/2,  100, 100);
        [_shareButton setBackgroundImage:[self sl_getImageFromBundle:@"video_share_hor"] forState:UIControlStateNormal];
        
        CGFloat toolViewH = 55;
        _toolView.frame = CGRectMake(0, playerW-toolViewH, playerH, toolViewH);
        _fullScreenButton.frame = CGRectMake(playerH-toolViewH, 0, toolViewH, toolViewH);
        
        _currentTimeLabel.frame = CGRectMake(0, (toolViewH-25)/2, 66, 25);
        _currentTimeLabel.font = [UIFont systemFontOfSize:18];
        _allTimeLabel.frame = CGRectMake(playerH - toolViewH - 66, (toolViewH-25)/2, 66, 25);
        _allTimeLabel.font = [UIFont systemFontOfSize:18];
        
        _bufferProgress.frame = CGRectMake(66+6, (toolViewH-2)/2, playerH - toolViewH - 66*2-12, 2);
        _progressSlider.frame = CGRectMake(66, (toolViewH-12)/2, playerH - toolViewH - 66*2, 12);
        [_progressSlider setThumbImage:[self sl_getImageFromBundle:@"silder_sel"] forState:UIControlStateNormal];
        
        _indicatorView.center = CGPointMake((playerH)/2, (playerW)/2);
        
//        _topNavView.hidden = NO;
        
//        _topNavView.frame = CGRectMake(0, 0, playerH, toolViewH);
    } else {
        
        _playOrPauseButton.frame = CGRectMake((playerW-100)/2, (playerH-100)/2, 100, 100);
        [_playOrPauseButton setBackgroundImage:[self sl_getImageFromBundle:@"play_hor"] forState:UIControlStateNormal];
        [_playOrPauseButton setBackgroundImage:[self sl_getImageFromBundle:@"pause_hor"] forState:UIControlStateSelected];
        
        _replayButton.frame = CGRectMake(playerW/2.0-100-16, (playerH-100)/2, 100, 100);
        [_replayButton setBackgroundImage:[self sl_getImageFromBundle:@"video_replay_hor"] forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(playerW/2.0+16, (playerH-100)/2, 100, 100);
        [_shareButton setBackgroundImage:[self sl_getImageFromBundle:@"video_share_hor"] forState:UIControlStateNormal];
        
        
        CGFloat toolViewH = 55;
        _toolView.frame = CGRectMake(0, playerH-toolViewH, playerH, toolViewH);
        _fullScreenButton.frame = CGRectMake(playerW-toolViewH, 0, toolViewH, toolViewH);
        
        
        _currentTimeLabel.frame = CGRectMake(0, (toolViewH-25)/2, 66, 25);
        _currentTimeLabel.font = [UIFont systemFontOfSize:18];
        _allTimeLabel.frame = CGRectMake(playerW - toolViewH - 66, (toolViewH-25)/2, 66, 25);
        _allTimeLabel.font = [UIFont systemFontOfSize:18];
        
        
        _bufferProgress.frame = CGRectMake(66+6, (toolViewH-2)/2, playerW - toolViewH - 66*2-12, 2);
        _progressSlider.frame = CGRectMake(66, (toolViewH-12)/2, playerW - toolViewH - 66*2, 12);
        [_progressSlider setThumbImage:[self sl_getImageFromBundle:@"silder_sel"] forState:UIControlStateNormal];
        
        _indicatorView.center = CGPointMake((playerW)/2, (playerH)/2);
     
//        _topNavView.hidden = NO;
        
//        _topNavView.frame = CGRectMake(playerH, playerH-toolViewH, playerH, toolViewH);
    }
}
- (void)hideFullScreenButton {
    self.fullScreenButton.hidden = YES;
    
    _fullHiden = YES;
}
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
        _playOrPauseButton.selected = YES;
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
    NSURL *url = [NSURL URLWithString:videoStr];
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    
    [_playerItem addOutput:_videoOutPut];
    
    
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    [self.player play];
    _playOrPauseButton.selected = YES;
    _isPlaying = YES;
    
    self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
    [self addObservers];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
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
        if (!_playOrPauseButton.hidden) {
            _toolView.hidden = YES;
            _playOrPauseButton.hidden = YES;
        } else {
            _toolView.hidden = NO;
            _playOrPauseButton.hidden = NO;
            self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
        }
    }
}
#pragma mark - silder
- (void)playerSliderTouchDown {
    [self.player pause];
}
- (void)playerSliderTouchUpInside {
    _isSliding = NO;
    [self.player play];
}
- (void)playerSliderValueChanged:(UISlider *)silder {
    _isSliding = YES;
    [self.player pause];
    self.playOrPauseButton.selected = NO;
    
    // 跳转到拖拽秒处
    CMTime changedTime = CMTimeMakeWithSeconds(silder.value, 1.0);
    [_playerItem seekToTime:changedTime completionHandler:^(BOOL finished) {
        // 跳转完成后做某事
        [self.player play];
        self.playOrPauseButton.selected = YES;
        
        self.time.fireDate = [NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]];
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
    _toolView.hidden = NO;
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
            _progressSlider.maximumValue = CMTimeGetSeconds(playerItem.duration);
            // 设置总视频时间
            _allTimeLabel.text = [self sl_formatVideoTime:[NSString stringWithFormat:@"%zd", (int)CMTimeGetSeconds(playerItem.duration)]];
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
            [_bufferProgress setProgress:timeInterval / totalDuration animated:YES];
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
            weakSelf.progressSlider.value = currentPlayTime;
            weakSelf.currentTimeLabel.text = [weakSelf sl_formatVideoTime:[NSString stringWithFormat:@"%zd", (int)currentPlayTime]];
        }
//        NSLog(@"%.2f", CMTimeGetSeconds(weakSelf.playerItem.currentTime));
        NSString *key = [NSString stringWithFormat:@"%.2f", CMTimeGetSeconds(weakSelf.playerItem.currentTime)];
        if ([weakSelf.dict.allKeys containsObject:key]) {
            NSLog(@"%@", [weakSelf.dict valueForKey:key]);
        }
    }];
}
#pragma mark - tool
- (UIImage *)sl_getImageFromBundle:(NSString *)imStr {
    NSString *str;
    
    str = [NSString stringWithFormat:@"SLVideoPlayer.bundle/images/%@.png", imStr];
    if ([UIScreen mainScreen].scale == 3) {
        str = [NSString stringWithFormat:@"SLVideoPlayer.bundle/images/%@@3x.png", imStr];
    }
    if ([UIScreen mainScreen].scale == 2) {
        str = [NSString stringWithFormat:@"SLVideoPlayer.bundle/images/%@@2x.png", imStr];
    }
    return [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:str]];
}
- (NSString *)sl_formatVideoTime:(NSString *)time {
    NSInteger t = [time integerValue];
    NSInteger seconds = t % 60;
    NSInteger minutes = (t / 60) % 60;
    NSInteger hours = t / 3600;
    //    NSString *str = [NSString stringWithFormat:@"%zd:%zd:%zd", hours, minutes, seconds];
    if (hours > 1) {
        return [NSString stringWithFormat:@"%zd:%zd:%zd", hours, minutes, seconds];
    }
    return [NSString stringWithFormat:@"%zd:%.2zd", minutes, seconds];
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
