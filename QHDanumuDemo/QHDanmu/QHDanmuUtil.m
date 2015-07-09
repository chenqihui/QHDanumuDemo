//
//  QHDanmuUtil.m
//  QHDanumuDemo
//
//  Created by chen on 15/6/28.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuUtil.h"

NSString * const kDanmuContentKey = @"c";
NSString * const kDanmuTimeKey = @"v";
NSString * const kDanmuOptionalKey = @"t";

@implementation QHDanmuUtil

+ (CGSize)getSizeWithString:(NSString *)str withFont:(UIFont *)font size:(CGSize)size {
    CGRect stringRect = [str boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{ NSFontAttributeName : font }
                                          context:nil];
    
    return stringRect.size;
}

+ (UIColor *)colorFromARGB:(int)argb {
    int blue = argb & 0xff;
    int green = argb >> 8 & 0xff;
    int red = argb >> 16 & 0xff;
    //int alpha = argb >> 24 & 0xff;
    //NSLog(@"%i, %i, %i", red, green, blue);
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha: 1];
}

+ (long)argbFromHex:(NSString *)hex
{
    const char *cStr = [hex cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr + 1, NULL, 16);
    return x;
    //    return [self colorFromARGB: (int)x];
}

+ (NSDictionary *)defaultOptions {
    return @{@"c": [NSNumber numberWithLong:[QHDanmuUtil argbFromHex: @"#ffffff"]],
             @"m": @"l",
             @"p": @"t",
             @"s": @"m",
             @"l": @"n"
             };
}

+ (NSDictionary *)randomOptions {
    NSUInteger c = arc4random_uniform(4);
    NSArray *arColor = @[@"#ffffff", @"#ff0000", @"#00ff00", @"#0000ff"];
    NSUInteger s = arc4random_uniform(3);
    NSArray *arFontSize = @[@"l", @"m", @"s"];
    NSUInteger m = arc4random_uniform(4);
    NSArray *arMode = @[@"l", @"f", @"l", @"l"];
    return @{@"c": [NSNumber numberWithLong:[QHDanmuUtil argbFromHex:arColor[c]]],
             @"m": arMode[m],
             @"p": @"t",
             @"s": arFontSize[s],
             @"l": @"n"
             };
}

+ (BOOL)isOrientationLandscape {
    //if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

@end
