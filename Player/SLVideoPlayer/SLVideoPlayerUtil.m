//
//  SLVideoPlayerUtil.m
//  Player
//
//  Created by sleen on 2018/3/9.
//  Copyright © 2018年 com.fireplain. All rights reserved.
//

#import "SLVideoPlayerUtil.h"

@implementation SLVideoPlayerUtil
+ (UIImage *)sl_getImageFromBundle:(NSString *)imStr {
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
+ (NSString *)sl_formatVideoTime:(NSString *)time {
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
@end
