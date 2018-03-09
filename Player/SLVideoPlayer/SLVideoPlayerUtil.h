//
//  SLVideoPlayerUtil.h
//  Player
//
//  Created by sleen on 2018/3/9.
//  Copyright © 2018年 com.fireplain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define SLColorRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
@interface SLVideoPlayerUtil : NSObject
+ (UIImage *)sl_getImageFromBundle:(NSString *)imStr;
+ (NSString *)sl_formatVideoTime:(NSString *)time;
@end
