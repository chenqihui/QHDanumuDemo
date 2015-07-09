//
//  QHDanmuLabel.h
//  QHDanumuDemo
//
//  Created by chen on 15/7/2.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QHDanmuUtil.h"

@interface QHDanmuLabel : UILabel

@property (nonatomic, strong, readonly) NSDictionary *info;
@property (nonatomic, readonly) DanmuState danmuState;
@property (nonatomic, readonly) CGFloat animationDuartion;
@property (nonatomic, strong, readonly) NSDictionary *dicOptional;

@property (nonatomic, readonly) CGFloat speed;
@property (nonatomic, readonly) CGFloat currentRightX;

@property (nonatomic, readonly) CGFloat startTime;
/**
 *  获取对应属性
 */
@property (nonatomic, getter=isFontSizeBig,     readonly) BOOL fontSizeBig;
@property (nonatomic, getter=isFontSizeMiddle,  readonly) BOOL fontSizeMiddle;
@property (nonatomic, getter=isFontSizeSmall,   readonly) BOOL fontSizeSmall;
@property (nonatomic, getter=isMoveModeRolling, readonly) BOOL moveModeRolling;
@property (nonatomic, getter=isMoveModeFadeOut, readonly) BOOL moveModeFadeOut;
@property (nonatomic, getter=isPositionTop,     readonly) BOOL positionTop;
@property (nonatomic, getter=isPositionMiddle,  readonly) BOOL positionMiddle;
@property (nonatomic, getter=isPositionBottom,  readonly) BOOL positionBottom;

+ (instancetype)createWithInfo:(NSDictionary *)info inView:(UIView *)view;

- (void)setDanmuChannel:(NSUInteger)channel offset:(CGFloat)xy;

- (void)animationDanmuItem:(NSTimeInterval)waitTime;

- (void)pause;

- (void)resume:(NSTimeInterval)nowTime;

- (void)removeDanmu;

@end
