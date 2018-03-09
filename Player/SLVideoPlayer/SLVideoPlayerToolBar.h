//
//  SLVideoPlayerToolBar.h
//  Player
//
//  Created by sleen on 2018/3/9.
//  Copyright © 2018年 com.fireplain. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SLVideoPlayerToolBarDelegate <NSObject>
@optional
- (void)barFullScreenButtonClick:(UIButton *)fullScreenButton;
- (void)barProgressSliderTouchDown;
- (void)barPlayerSliderTouchUpInside;
- (void)barPlayerSliderValueChanged:(UISlider *)progressSlider;
@end
@interface SLVideoPlayerToolBar : UIView
@property (nonatomic, strong) UIProgressView *bufferProgress;    ///< 缓冲进度条
@property (nonatomic, strong) UISlider *progressSlider;  ///< 播放进度条
@property (nonatomic, strong) UILabel *currentTimeLabel;     ///< 播放时间
@property (nonatomic, strong) UILabel *allTimeLabel;         ///< 时间总长
@property (nonatomic, strong) UIButton *fullScreenButton;    ///< 全屏按钮

@property (nonatomic, weak) id<SLVideoPlayerToolBarDelegate> delegate;
@end
