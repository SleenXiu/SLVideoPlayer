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
    [self.view addSubview:player];
    [player playVideoWithStr:@"https://video.deeppp.com/7325faf9ca1b483f7c111986f2764a68"];
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
