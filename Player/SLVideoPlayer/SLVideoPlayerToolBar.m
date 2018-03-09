//
//  SLVideoPlayerToolBar.m
//  Player
//
//  Created by sleen on 2018/3/9.
//  Copyright © 2018年 com.fireplain. All rights reserved.
//

#import "SLVideoPlayerToolBar.h"
#import "SLVideoPlayerUtil.h"

@implementation SLVideoPlayerToolBar
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = SLColorRGBA(0, 0, 0, 0.3);
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.allTimeLabel];

    [self addSubview:self.bufferProgress];
    [self addSubview:self.progressSlider];
    [self addSubview:self.fullScreenButton];
    
    
    [self setupLayoutConstraint];
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
}
- (void)setupLayoutConstraint {
    CGFloat margin = 8;
    
    NSLayoutConstraint *currentTimeLabel_left = [NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0 constant:0];
    NSLayoutConstraint *currentTimeLabel_centerY = [NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0 constant:0];
    NSLayoutConstraint *currentTimeLabel_width = [NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1.0 constant:46];
    [self addConstraints:@[currentTimeLabel_left, currentTimeLabel_centerY, currentTimeLabel_width]];
    
    
    NSLayoutConstraint *fullScreenButton_width = [NSLayoutConstraint constraintWithItem:self.fullScreenButton
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0 constant:0];
    NSLayoutConstraint *fullScreenButton_height = [NSLayoutConstraint constraintWithItem:self.fullScreenButton
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0 constant:0];
    NSLayoutConstraint *fullScreenButton_right = [NSLayoutConstraint constraintWithItem:self.fullScreenButton
                                                                              attribute:NSLayoutAttributeRight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeRight
                                                                             multiplier:1.0 constant:0];
    NSLayoutConstraint *fullScreenButton_top = [NSLayoutConstraint constraintWithItem:self.fullScreenButton
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0 constant:0];
     [self addConstraints:@[fullScreenButton_width, fullScreenButton_height, fullScreenButton_right, fullScreenButton_top]];

    
    NSLayoutConstraint *allTimeLabel_right = [NSLayoutConstraint constraintWithItem:self.allTimeLabel
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.fullScreenButton
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0 constant:0-margin+4];
    NSLayoutConstraint *allTimeLabel_centerY = [NSLayoutConstraint constraintWithItem:self.allTimeLabel
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterY
                                                                               multiplier:1.0 constant:0];
    [self addConstraints:@[allTimeLabel_right, allTimeLabel_centerY]];


    NSLayoutConstraint *bufferProgress_centerY = [NSLayoutConstraint constraintWithItem:self.bufferProgress
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.0 constant:0.5];
    NSLayoutConstraint *bufferProgress_left = [NSLayoutConstraint constraintWithItem:self.bufferProgress
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.currentTimeLabel
                                                                              attribute:NSLayoutAttributeRight
                                                                             multiplier:1.0 constant:0];
    NSLayoutConstraint *bufferProgress_right = [NSLayoutConstraint constraintWithItem:self.bufferProgress
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.allTimeLabel
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0 constant:0-margin];
    [self addConstraints:@[bufferProgress_centerY, bufferProgress_left, bufferProgress_right]];

    NSLayoutConstraint *progressSlider_centerY = [NSLayoutConstraint constraintWithItem:self.progressSlider
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.0 constant:0];
    NSLayoutConstraint *progressSlider_left = [NSLayoutConstraint constraintWithItem:self.progressSlider
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.currentTimeLabel
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0 constant:0];
    NSLayoutConstraint *progressSlider_right = [NSLayoutConstraint constraintWithItem:self.progressSlider
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.allTimeLabel
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:0-margin];
    [self addConstraints:@[progressSlider_centerY, progressSlider_left, progressSlider_right]];
    
    [self setNeedsUpdateConstraints];
}
#pragma mark - event
- (void)playerSliderValueChanged:(UISlider *)progressSlider {
    if ([self.delegate respondsToSelector:@selector(barPlayerSliderValueChanged:)]) {
        [self.delegate barPlayerSliderValueChanged:progressSlider];
    }
}
- (void)playerSliderTouchUpInside {
    if ([self.delegate respondsToSelector:@selector(barPlayerSliderTouchUpInside)]) {
        [self.delegate barPlayerSliderTouchUpInside];
    }
}
- (void)playerSliderTouchDown {
    if ([self.delegate respondsToSelector:@selector(barProgressSliderTouchDown)]) {
        [self.delegate barProgressSliderTouchDown];
    }
}
- (void)fullScreenButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(barFullScreenButtonClick:)]) {
        [self.delegate barFullScreenButtonClick:button];
    }
}
#pragma mark - getter
/*
 @property (nonatomic, strong) UIProgressView *bufferProgress;    ///< 缓冲进度条
 @property (nonatomic, strong) UISlider *progressSlider;  ///< 播放进度条
 @property (nonatomic, strong) UILabel *currentTimeLabel;     ///< 播放时间
 @property (nonatomic, strong) UILabel *allTimeLabel;         ///< 时间总长
 @property (nonatomic, strong) UIButton *fullScreenButton;    ///< 全屏按钮
 */
- (UIProgressView *)bufferProgress {
    if (!_bufferProgress) {
        _bufferProgress = [[UIProgressView alloc] init];
        _bufferProgress.progressViewStyle = UIProgressViewStyleDefault;
        _bufferProgress.progressTintColor = SLColorRGBA(204, 204, 204, 1.0);
        _bufferProgress.trackTintColor = SLColorRGBA(136, 136, 136, 1.0);
        for (UIImageView * imageview in _bufferProgress.subviews) {
            imageview.layer.cornerRadius = 1;
            imageview.clipsToBounds = YES;
        }
        
        _bufferProgress.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bufferProgress;
}
- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.backgroundColor = [UIColor clearColor];
        //    [_progressSlider setThumbImage:[UIImage imageWithNoCacheName:@"slider"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:SLColorRGBA(255, 255, 255, 1.0)];
        [_progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
        [_progressSlider addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(playerSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(playerSliderTouchDown) forControlEvents:UIControlEventTouchDown];
        [_progressSlider setThumbImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"silder_normal"] forState:UIControlStateNormal];
        
        for (UIImageView * imageview in _bufferProgress.subviews) {
            imageview.layer.cornerRadius = imageview.frame.size.height/2.0;
            imageview.clipsToBounds = YES;
        }
        _progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _progressSlider;
}
- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.font = [UIFont systemFontOfSize:10];
        [_currentTimeLabel sizeToFit];
        _currentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _currentTimeLabel;
}
- (UILabel *)allTimeLabel {
    if (!_allTimeLabel) {
        _allTimeLabel = [[UILabel alloc] init];
        _allTimeLabel.textColor = [UIColor whiteColor];
        _allTimeLabel.textAlignment = NSTextAlignmentCenter;
        _allTimeLabel.text = @"00:00";
        _allTimeLabel.font = [UIFont systemFontOfSize:10];
        [_allTimeLabel sizeToFit];
        
        _allTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _allTimeLabel;
}
- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"full_screen_nor"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[SLVideoPlayerUtil sl_getImageFromBundle:@"full_screen_sel"] forState:UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _fullScreenButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _fullScreenButton;
}
@end
