//
//  QHDanmuUtil.h
//  QHDanumuDemo
//
//  Created by chen on 15/6/28.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DanmuState) {
    DanmuStateStop = 1,
    DanmuStateAnimationing,
    DanmuStateFinish
};

#define CHANNEL_HEIGHT 25

/**
 *  弹幕属性key
 */
extern NSString * const kDanmuContentKey;//弹幕内容
extern NSString * const kDanmuTimeKey;//视频时间
extern NSString * const kDanmuOptionalKey;//弹幕样式

@interface QHDanmuUtil : NSObject

+ (CGSize)getSizeWithString:(NSString *)str withFont:(UIFont *)font size:(CGSize)size;

+ (UIColor *)colorFromARGB:(int)argb;
/**
 *  t:df(使用默认样式，样式替换成dfopt中的样式)
 *
 *  @return
 */
+ (NSDictionary *)defaultOptions;
/**
 *  随机样式
 *
 *  @return
 */
+ (NSDictionary *)randomOptions;
/**
 *  横竖屏判断，是否横屏
 *
 *  @return
 */
+ (BOOL)isOrientationLandscape;

@end
