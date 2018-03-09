//
//  ViewController.m
//  Player
//
//  Created by sleen on 2018/3/9.
//  Copyright © 2018年 com.fireplain. All rights reserved.
//

#import "ViewController.h"

#import "SLVideoPlayer.h"
#import "SLVideoPlayerToolBar.h"
@interface ViewController () <SLVideoPlayerToolBarDelegate>
@property (nonatomic, weak) SLVideoPlayerToolBar *t;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    SLVideoPlayerToolBar *t = [[SLVideoPlayerToolBar alloc] init];
//    t.frame = CGRectMake((self.view.frame.size.width-320)*0.5, 200, 320, 24);
//    [t layoutIfNeeded];
//    t.delegate = self;
//    [self.view addSubview:t];
//    self.t = t;
    [self haha];
}
- (void)barFullScreenButtonClick:(UIButton *)fullScreenButton {
    
}
- (void)haha {
    SLVideoPlayer *player = [[SLVideoPlayer alloc] init];
    player.frame = CGRectMake((self.view.frame.size.width-320)*0.5, 200, 320, 240);
    [player updateWidgetsShow];
    [self.view addSubview:player];
    
    [player playVideoWithStr:@"https://video.deeppp.com/7325faf9ca1b483f7c111986f2764a68"];
    __weak typeof(player) weakPlayer = player;
    __weak typeof(self) weakSelf = self;
    [player addFullScreenBlock:^(UIButton *fullScreenBtn) {
        if (fullScreenBtn.selected) {
            if(weakPlayer.showType == SLVideoViewShowTypeHorizontal){
                weakPlayer.normalFrame = weakPlayer.frame;
                weakPlayer.normalParentView = weakPlayer.superview;
                
                CGRect rectInWindow = [weakPlayer.superview convertRect:weakPlayer.frame toView:[UIApplication sharedApplication].keyWindow];
                [weakPlayer removeFromSuperview];
                weakPlayer.frame = rectInWindow;
                [[UIApplication sharedApplication].keyWindow addSubview:weakPlayer];
                
                [UIView animateWithDuration:0.5 animations:^{
                    weakPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
                    weakPlayer.bounds = CGRectMake(0, 0, CGRectGetHeight(weakPlayer.superview.bounds), CGRectGetWidth(weakPlayer.superview.bounds));
                    weakPlayer.center = CGPointMake(CGRectGetMidX(weakPlayer.superview.bounds), CGRectGetMidY(weakPlayer.superview.bounds));
                    
                    [weakPlayer updateWidgetsShow];
                } completion:^(BOOL finished) {
                }];
                [weakSelf refreshStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                
            } else {
                weakPlayer.normalFrame = weakPlayer.frame;
                weakPlayer.normalParentView = weakPlayer.superview;
                
                CGRect rectInWindow = [weakPlayer.superview convertRect:weakPlayer.frame toView:[UIApplication sharedApplication].keyWindow];
                [weakPlayer removeFromSuperview];
                weakPlayer.frame = rectInWindow;
                [[UIApplication sharedApplication].keyWindow addSubview:weakPlayer];
                
                [UIView animateWithDuration:0.5 animations:^{
                    weakPlayer.bounds = CGRectMake(0, 0, CGRectGetWidth(weakPlayer.superview.bounds), CGRectGetHeight(weakPlayer.superview.bounds));
                    weakPlayer.center = CGPointMake(CGRectGetMidX(weakPlayer.superview.bounds), CGRectGetMidY(weakPlayer.superview.bounds));
                    
                    [weakPlayer updateWidgetsShow];
                } completion:^(BOOL finished) {
                }];
            }
        } else {
            CGRect frame = [weakPlayer.normalParentView convertRect:weakPlayer.normalFrame toView:[UIApplication sharedApplication].keyWindow];
            [UIView animateWithDuration:0.5 animations:^{
                
                weakPlayer.transform = CGAffineTransformIdentity;
                weakPlayer.frame = frame;
                weakPlayer.showType = SLVideoViewShowTypeNormal;
                [weakPlayer updateWidgetsShow];
                
            } completion:^(BOOL finished) {
                
                [weakPlayer removeFromSuperview];
                weakPlayer.frame = weakPlayer.normalFrame;
                [weakPlayer.normalParentView addSubview:weakPlayer];
            }];
            
            [weakSelf refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
            
            //            [[UIApplication sharedApplication] setStatusBarStyle:weakPlayer.oldStyle];
        }
    }];
}
- (void)refreshStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate {
    return NO;
}

@end
