//
//  QHDanmuLabel.m
//  QHDanumuDemo
//
//  Created by chen on 15/7/2.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuLabel.h"

static NSString * const DANMU_FONT_SIZE_BIG = @"l";
static NSString * const DANMU_FONT_SIZE_MIDDLE = @"m";
static NSString * const DANMU_FONT_SIZE_SMALL = @"s";

static NSString * const DANMU_MOVE_MODE_ROLLING = @"l";
static NSString * const DANMU_MOVE_MODE_FADEOUT = @"f";

static NSString * const DANMU_POSITION_TOP = @"t";
static NSString * const DANMU_POSITION_MIDDLE = @"m";
static NSString * const DANMU_POSITION_BOTTOM = @"b";

#define ARC4RANDOM_MAX      0x100000000

#define ROLL_ANIMATION_DURATION_TIME 5

#define FADE_ANIMATION_DURATION_TIME 2
#define ANIMATION_DELAY_TIME 3

@interface QHDanmuLabel ()

@property (nonatomic, strong, readwrite) NSDictionary *info;
@property (nonatomic, readwrite) DanmuState danmuState;
@property (nonatomic, readwrite) CGFloat animationDuartion;
@property (nonatomic, strong, readwrite) NSDictionary *dicOptional;

@property (nonatomic, readwrite) CGFloat speed;
@property (nonatomic, readwrite) CGFloat currentRightX;

@property (nonatomic) NSUInteger nChannel;
@property (nonatomic, weak)   UIView *superView;

@property (nonatomic) CGFloat originalX;

@end

@implementation QHDanmuLabel

- (void)dealloc {
    _info = nil;
    _dicOptional = nil;
}

#pragma mark - Private

- (void)p_initData {
    self.textColor = [UIColor blackColor];
    // 弹幕颜色
//    id optional = [self.info objectForKey:kDanmuOptionalKey];
//    if ([optional isKindOfClass:[NSString class]]) {
//        optional = [QHDanmuUtil defaultOptions];
//    }
    id optional = [QHDanmuUtil randomOptions];
    self.dicOptional = [NSDictionary dictionaryWithDictionary:optional];
    
    int color = [[optional objectForKey:@"c"] intValue];
    [self setTextColor:[QHDanmuUtil colorFromARGB: color]];
    
    CGFloat fontsize = 15;
    if (self.isFontSizeBig) {
        fontsize = 19;
    }else if (self.isFontSizeMiddle) {
        fontsize = 17;
    }
    
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    self.font = font;
    
    NSString *content = [_info objectForKey:kDanmuContentKey];
    self.text = content;
}

- (void)p_initFrame:(CGFloat)offsetX {
    if (self.isMoveModeFadeOut) {
        NSInteger plus = ((arc4random() % 2) + 1) == 1 ? 1 : -1;
        offsetX = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 30.0f)*plus;
        NSString *content = [self.info objectForKey:kDanmuContentKey];
        CGSize size = [QHDanmuUtil getSizeWithString:content withFont:self.font size:(CGSize){MAXFLOAT, CHANNEL_HEIGHT}];
        CGRect frame = (CGRect){(CGPoint){0, 0}, size};
        self.frame = frame;
        
        CGPoint center = _superView.center;
        center.x += offsetX;
        self.center = center;
    }
    else {
        NSString *content = [self.info objectForKey:kDanmuContentKey];
        CGSize size = [QHDanmuUtil getSizeWithString:content withFont:self.font size:(CGSize){MAXFLOAT, CHANNEL_HEIGHT}];
        CGRect frame = (CGRect){(CGPoint){_superView.frame.size.width + offsetX, 0}, size};
        self.frame = frame;
        _originalX = frame.origin.x + frame.size.width;
    }
}

- (void)p_rollAnimation:(CGFloat)time delay:(NSTimeInterval)waitTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.danmuState = DanmuStateAnimationing;
        [UIView animateWithDuration:time delay:waitTime options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect frame = self.frame;
            frame.origin.x = -self.frame.size.width;
            self.frame = frame;
        } completion:^(BOOL finished) {
            if (finished)
                [self removeDanmu];
        }];
    });
}

- (void)p_fadeAnimation:(CGFloat)time delay:(NSTimeInterval)disappearTime waitTime:(NSTimeInterval)waitTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (waitTime == 0) {
            self.alpha = 1;
            self.danmuState = DanmuStateAnimationing;
            [UIView animateWithDuration:time delay:disappearTime options:UIViewAnimationOptionCurveLinear animations:^{
                self.alpha = 0.2;
            } completion:^(BOOL finished) {
                if (finished)
                    [self removeDanmu];
            }];
        }
        else {
            self.alpha = 0;
            [UIView animateWithDuration:0 delay:waitTime options:UIViewAnimationOptionCurveLinear animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished) {
                self.danmuState = DanmuStateAnimationing;
                [UIView animateWithDuration:time delay:disappearTime options:UIViewAnimationOptionCurveLinear animations:^{
                    self.alpha = 0.2;
                } completion:^(BOOL finished) {
                    if (finished)
                        [self removeDanmu];
                }];
            }];
        }
    });
}

#pragma mark - Action

+ (instancetype)createWithInfo:(NSDictionary *)info inView:(UIView *)view {
    QHDanmuLabel *danmuLabel = [[QHDanmuLabel alloc] init];
    
    danmuLabel.info = info;
    danmuLabel.superView = view;
    danmuLabel.nChannel = 0;
    
    [danmuLabel p_initData];
    [danmuLabel p_initFrame:0];
    
    return danmuLabel;
}

- (void)setDanmuChannel:(NSUInteger)channel offset:(CGFloat)xy {
    if (self.isMoveModeFadeOut) {
        self.danmuState = DanmuStateStop;
        self.nChannel = channel;
        CGRect frame = self.frame;
        frame.origin.y = CHANNEL_HEIGHT*_nChannel + xy;
        self.frame = frame;
        [_superView addSubview:self];
    }
    else {
        self.danmuState = DanmuStateStop;
        self.nChannel = channel;
        CGRect frame = self.frame;
        frame.origin.x += xy;
        frame.origin.y = CHANNEL_HEIGHT*_nChannel;
        self.frame = frame;
        _originalX = frame.origin.x + frame.size.width;
        [_superView addSubview:self];
    }
}

- (void)animationDanmuItem:(NSTimeInterval)waitTime {
    if (self.isMoveModeFadeOut) {
        [self p_fadeAnimation:FADE_ANIMATION_DURATION_TIME delay:ANIMATION_DELAY_TIME waitTime:waitTime];
    }
    else {
        [self p_rollAnimation:self.animationDuartion delay:waitTime];
    }
}

- (void)pause {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isMoveModeFadeOut) {
            //    self.danmuState = DanmuStateStop;
            //    self.alpha = 1.0;
            //    [self.layer removeAllAnimations];
        }
        else {
            self.danmuState = DanmuStateStop;
            UIView *view = self;
            CALayer *layer = view.layer;
            CGRect rect = view.frame;
            if (layer.presentationLayer) {
                rect = ((CALayer *)layer.presentationLayer).frame;
    //            rect.origin.x -= 1;
            }
            view.frame = rect;
            [view.layer removeAllAnimations];
        }
    });
}

- (void)resume:(NSTimeInterval)nowTime {
    if (self.isMoveModeFadeOut) {
        //    CGFloat startTime = self.startTime;
        //    CGFloat time = nowTime - startTime;
        //
        //    CGFloat waitTime = self.startTime;
        //    if (waitTime > nowTime)
        //        waitTime = waitTime - nowTime;
        //    else
        //        waitTime = 0;
        //
        //    if (waitTime > 0) {
        //        [self p_fadeAnimation:self.animationDuartion delay:ANIMATION_DELAY_TIME waitTime:waitTime];
        //    }
        //    else {
        //        [self p_fadeAnimation:time delay:ANIMATION_DELAY_TIME waitTime:0];
        //    }
        if (self.danmuState == DanmuStateStop)
            [self p_fadeAnimation:FADE_ANIMATION_DURATION_TIME delay:ANIMATION_DELAY_TIME waitTime:0];
    }
    else {
        CGFloat waitTime = self.startTime;
        if (waitTime > nowTime)
            waitTime = waitTime - nowTime;
        else
            waitTime = 0;
        
        CGFloat time = (self.frame.origin.x + self.frame.size.width)/self.speed;
        [self p_rollAnimation:time delay:waitTime];
    }
}

- (void)removeDanmu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isMoveModeFadeOut) {
            self.danmuState = DanmuStateFinish;
            [self.layer removeAllAnimations];
            [self removeFromSuperview];
        }
        else {
            self.danmuState = DanmuStateFinish;
            [self.layer removeAllAnimations];
            [self removeFromSuperview];
        }
    });
}

#pragma mark - Get

- (CGFloat)speed {
    _speed = _originalX/self.animationDuartion;
    return _speed;
}

- (CGFloat)animationDuartion {
    if (self.isMoveModeFadeOut) {
        //如果是竖屏
        _animationDuartion = FADE_ANIMATION_DURATION_TIME + ANIMATION_DELAY_TIME;
        //如果是横屏，根据不同尺寸，可能有不同的总时间
    }
    else {
        _animationDuartion = ROLL_ANIMATION_DURATION_TIME;
    }
    return _animationDuartion;
}

- (CGFloat)currentRightX {
    switch (self.danmuState) {
        case DanmuStateStop: {
            _currentRightX = CGRectGetMaxX(self.frame) - _superView.frame.size.width;
            break;
        }
        case DanmuStateAnimationing: {
            CALayer *layer = self.layer;
            _currentRightX = _originalX;
            if (layer.presentationLayer)
                _currentRightX = ((CALayer *)layer.presentationLayer).frame.origin.x + self.frame.size.width;
            _currentRightX -= _superView.frame.size.width;
            break;
        }
        case DanmuStateFinish: {
            _currentRightX = -_superView.frame.size.width;
            break;
        }
        default: {
            break;
        }
    }
    return _currentRightX;
}

#pragma mark -

- (CGFloat)startTime {
    return [[self.info valueForKey:kDanmuTimeKey] floatValue];
}

- (NSString *)fontSize {
    return [self.dicOptional valueForKey: @"s"];
}

- (NSString *)moveMode {
    return [self.dicOptional valueForKey: @"m"];
}

- (NSString *)position {
    return [self.dicOptional valueForKey: @"p"];
}

- (BOOL)isFontSizeBig {
    return [[self fontSize] isEqualToString: DANMU_FONT_SIZE_BIG];
}

- (BOOL)isFontSizeMiddle {
    return [[self fontSize] isEqualToString: DANMU_FONT_SIZE_MIDDLE];
}

- (BOOL)isFontSizeSmall {
    return [[self fontSize] isEqualToString: DANMU_FONT_SIZE_SMALL];
}

- (BOOL)isMoveModeRolling {
    return [[self moveMode] isEqualToString: DANMU_MOVE_MODE_ROLLING];
}

- (BOOL)isMoveModeFadeOut {
    return [[self moveMode] isEqualToString: DANMU_MOVE_MODE_FADEOUT];
}

- (BOOL)isPositionTop {
    return [[self position] isEqualToString: DANMU_POSITION_TOP];
}

- (BOOL)isPositionMiddle {
    return [[self position] isEqualToString: DANMU_POSITION_MIDDLE];
}

- (BOOL)isPositionBottom {
    return [[self position] isEqualToString: DANMU_POSITION_BOTTOM];
}

@end
