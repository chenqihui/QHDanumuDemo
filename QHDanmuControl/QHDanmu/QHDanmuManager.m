//
//  QHDanmuManager.m
//  QHDanumuDemo
//
//  Created by chen on 15/6/28.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuManager.h"

#import "QHDanmuLabel.h"
#import "QHDanmuView.h"

#define CHANNEL_WIDTH_MAX 120
#define CHANNEL_SPACE 10

struct DanmuPositionStruct {
    NSInteger start;
    NSInteger length;
};
typedef struct DanmuPositionStruct DanmuPositionStruct;

@interface QHDanmuManager ()

@property (nonatomic, strong, readwrite) UIView *danmuView;
@property (nonatomic, readwrite) DanmuManagerState danmuManagerState;

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) NSMutableArray *infos;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic) NSUInteger durationTime;//添加弹幕的间隔时间
@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *arRollChannelInfo;
@property (nonatomic, strong) NSMutableArray *arFadeChannelInfo;
@property (nonatomic) NSUInteger countChannel;

@property (nonatomic) DanmuPositionStruct upPosition;
@property (nonatomic) DanmuPositionStruct middlePosition;
@property (nonatomic) DanmuPositionStruct downPosition;

@property (nonatomic) DanmuPositionStruct upFadeOnePosition;
@property (nonatomic) DanmuPositionStruct middleFadeOnePosition;
@property (nonatomic) DanmuPositionStruct downFadeOnePosition;

@property (nonatomic) DanmuPositionStruct upFadeTwoPosition;
@property (nonatomic) DanmuPositionStruct middleFadeTwoPosition;
@property (nonatomic) DanmuPositionStruct downFadeTwoPosition;

@property (nonatomic) dispatch_queue_t danmuQueue;

@end

@implementation QHDanmuManager

- (void)dealloc {
    _infos = nil;
    _danmuView = nil;
    _arRollChannelInfo = nil;
    _arFadeChannelInfo = nil;
}

- (instancetype)initWithFrame:(CGRect)frame data:(NSArray *)infos inView:(UIView *)view durationTime:(NSUInteger)time {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.infos = [infos mutableCopy];
        self.superView = view;
        self.durationTime = time;
        
        self.danmuQueue = dispatch_queue_create("com.danmu.queue", NULL);
        
        [self p_initInfo];
    }
    return self;
}

#pragma mark - Private

- (void)p_initInfo {
    _countChannel = self.frame.size.height/CHANNEL_HEIGHT;
    
    self.arRollChannelInfo = [NSMutableArray arrayWithCapacity:_countChannel];
    self.arFadeChannelInfo = [NSMutableArray arrayWithCapacity:2];
    
    NSUInteger sectionLines = nearbyintf((CGFloat)_countChannel / 3);
    NSUInteger firstLines = MAX(_countChannel - sectionLines*2, sectionLines);
    //滚动航道布局
    {
        //上中下，假设10，上：0-3，中：4-6，下：7-9
        _upPosition = (DanmuPositionStruct){0, firstLines};
        _middlePosition = (DanmuPositionStruct){_upPosition.length, sectionLines};
        _downPosition = (DanmuPositionStruct){_middlePosition.start + _middlePosition.length, _countChannel - _middlePosition.start - _middlePosition.length};
        //上中下，假设10，上：0-9，中：4-9，下：7-9
        _upPosition = (DanmuPositionStruct){0, _countChannel};
        _middlePosition = (DanmuPositionStruct){firstLines, _upPosition.length - firstLines};
        _downPosition = (DanmuPositionStruct){_middlePosition.start + sectionLines, _upPosition.length - firstLines - sectionLines};
    }
    //浮现航道布局，这里选择的是上面滚动航道布局，所以不一定是现在这样子
    {
        //第一层：上中下，假设10，上：0-9，中：4-9，下：7-9，
        _upFadeOnePosition = _upPosition;
        _middleFadeOnePosition = _middlePosition;
        _downFadeOnePosition = _downPosition;
        //由于上一层为10，第二层为9，上：0-8，中：4-8，下：7-8
        _upFadeTwoPosition = (DanmuPositionStruct){_upFadeOnePosition.start, _upFadeOnePosition.length - 1};
        _middleFadeTwoPosition = (DanmuPositionStruct){_middleFadeOnePosition.start, _middleFadeOnePosition.length - 1};
        _downFadeTwoPosition = (DanmuPositionStruct){_downFadeOnePosition.start, _downFadeOnePosition.length - 1};
    }
    
    _danmuManagerState = DanmuManagerStateWait;
}

- (void)p_initData {
    [self.arRollChannelInfo removeAllObjects];
    
    for (int i = 0; i < _countChannel; i++) {
        [self.arRollChannelInfo addObject:[NSNumber numberWithInt:i]];
    }
    
    [self.arFadeChannelInfo removeAllObjects];
    
    NSMutableArray *ar1 = [NSMutableArray new];
    for (int i = 0; i < _countChannel; i++) {
        [ar1 addObject:[NSNumber numberWithInt:i]];
    }
    [self.arFadeChannelInfo addObject:ar1];
    NSMutableArray *ar2 = [NSMutableArray new];
    for (int i = 0; i < _countChannel - 1; i++) {
        [ar2 addObject:[NSNumber numberWithInt:i]];
    }
    [self.arFadeChannelInfo addObject:ar2];
    
    self.currentIndex = 0;
    
    [self.danmuView removeFromSuperview];
    self.danmuView = nil;
    self.danmuView = [[QHDanmuView alloc] initWithFrame:_frame];
    [self.superView addSubview:self.danmuView];
    
    _danmuManagerState = DanmuManagerStateWait;
}

- (void)p_danmu:(NSTimeInterval)startTime {
    __weak typeof(self) weakSelf = self;
    
    __block NSMutableArray *danmuInfos = [NSMutableArray new];
    __block NSUInteger index = 0;
    
    for (int i = (int)self.currentIndex; i < self.infos.count; i++) {
        NSDictionary *obj = [self.infos objectAtIndex:i];
        CGFloat time = [[obj objectForKey:kDanmuTimeKey] floatValue];
        if (time >= startTime && time < startTime + weakSelf.durationTime) {
            [danmuInfos addObject:obj];
        }
        if (time >= startTime + weakSelf.durationTime) {
            index = i;
            break;
        }
    }
    
    if (danmuInfos.count > 0) {
        self.currentIndex = index;
        
        void(^func)(QHDanmuLabel *danmuLabel, NSUInteger idx, CGFloat offsetXY) = ^(QHDanmuLabel *danmuLabel, NSUInteger idx, CGFloat offsetXY){
            if (idx != NSNotFound) {
                [danmuLabel setDanmuChannel:idx offset:offsetXY];
                CGFloat time = [danmuLabel startTime];
                time = time - startTime;
                [danmuLabel animationDanmuItem:time];
            }
        };
        
        [danmuInfos enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            __block QHDanmuLabel *danmuLabel = [QHDanmuLabel createWithInfo:obj inView:weakSelf.danmuView];
            if ([danmuLabel isMoveModeFadeOut]) {
                [weakSelf p_getFadeBestChannel:danmuLabel completion:^(NSUInteger idx, CGFloat offsetY) {
                    func(danmuLabel, idx, offsetY);
                }];
            }
            else {
                [weakSelf p_getRollBestChannel:danmuLabel completion:^(NSUInteger idx, CGFloat offsetX) {
                    func(danmuLabel, idx, offsetX);
                }];
            }
        }];
    }
}

- (void)p_getRollBestChannel:(QHDanmuLabel *)newDanmuL completion:(void(^)(NSUInteger idx, CGFloat offsetX))completion {
    DanmuPositionStruct danmuPosition;
    if (newDanmuL.isPositionMiddle) {
        danmuPosition = _middlePosition;
    }
    else if (newDanmuL.isPositionBottom) {
        danmuPosition = _downPosition;
    }
    else {
        danmuPosition = _upPosition;
    }
    
    NSUInteger index = danmuPosition.start;
    BOOL bFind = NO;
    for (int i = (int)danmuPosition.start; i < danmuPosition.start + danmuPosition.length; i++) {
        id obj = [self.arRollChannelInfo objectAtIndex:i];
        index = i;
        if ([obj isKindOfClass:[QHDanmuLabel class]]) {
            bFind = [self p_last:obj new:newDanmuL];
        }else {
            bFind = YES;
        }
        
        if (bFind)
            break;
    }
    
    if (bFind) {
        id obj = [self.arRollChannelInfo objectAtIndex:index];
        [self.arRollChannelInfo replaceObjectAtIndex:index withObject:newDanmuL];
        if ([obj isKindOfClass:[QHDanmuLabel class]]) {
            CGFloat x = ((QHDanmuLabel *)obj).currentRightX;
            completion(index, x < 0 ? 0 : x);
        }else
            completion(index, 0);
    }else {
        if (index < danmuPosition.start + danmuPosition.length - 1) {
            index += 1;
            [self.arRollChannelInfo replaceObjectAtIndex:index withObject:newDanmuL];
            completion(index, 0);
        }
        else {
            NSUInteger index = NSNotFound;
            index = [self p_allChannelWithPosition:danmuPosition new:newDanmuL];
            if (index != NSNotFound) {
                QHDanmuLabel *obj = [self.arRollChannelInfo objectAtIndex:index];
                [self.arRollChannelInfo replaceObjectAtIndex:index withObject:newDanmuL];
                CGFloat x = obj.currentRightX;
                completion(index, x < CHANNEL_SPACE ? CHANNEL_SPACE : x);
            }else
                completion(NSNotFound, 0);
        }
    }
}

//选择完全不会碰撞的航道
- (BOOL)p_last:(QHDanmuLabel *)lastDanmuL new:(QHDanmuLabel *)newDanmuL {
    CGFloat durationTime = newDanmuL.startTime - lastDanmuL.startTime;
    if (durationTime > newDanmuL.animationDuartion) {
        return YES;
    }
    CGFloat timeS = lastDanmuL.frame.size.width/lastDanmuL.speed;
    if (timeS >= durationTime) {
        return NO;
    }
    CGFloat timeE = newDanmuL.currentRightX/newDanmuL.speed;
    if (timeE <= durationTime) {
        return NO;
    }
    
    return YES;
}

//选择在不超出缓冲区的且缓冲区最长的航道
- (NSUInteger)p_allChannelWithPosition:(DanmuPositionStruct)danmuPosition new:(QHDanmuLabel *)newDanmuL {
    CGFloat width = CHANNEL_WIDTH_MAX;
    NSUInteger index = NSNotFound;
    for (int i = (int)danmuPosition.start; i < danmuPosition.start + danmuPosition.length; i++) {id obj = [self.arRollChannelInfo objectAtIndex:i];
        if ([obj isKindOfClass:[QHDanmuLabel class]]) {
            CGFloat rightX = ((QHDanmuLabel *)obj).currentRightX;
            if (rightX <= CHANNEL_WIDTH_MAX) {
                CGFloat xx = rightX;
                if (xx < width) {
                    width = xx;
                    index = i;
                }
            }
        }
    }
    
    return index;
}

- (void)p_getFadeBestChannel:(QHDanmuLabel *)newDanmuL completion:(void(^)(NSUInteger idx, CGFloat offsetY))completion {
    DanmuPositionStruct danmuOnePosition;
    DanmuPositionStruct danmuTwoPosition;
    if (newDanmuL.isPositionMiddle) {
        danmuOnePosition = _middleFadeOnePosition;
        danmuTwoPosition = _middleFadeTwoPosition;
    }else if (newDanmuL.isPositionBottom) {
        danmuOnePosition = _downFadeOnePosition;
        danmuTwoPosition = _downFadeTwoPosition;
    }else {
        danmuOnePosition = _upFadeOnePosition;
        danmuTwoPosition = _upFadeTwoPosition;
    }
    NSMutableArray *ar1 = [self.arFadeChannelInfo objectAtIndex:0];
    NSMutableArray *ar2 = [self.arFadeChannelInfo objectAtIndex:1];
    
    NSUInteger index = [self p_arDanmuLabel:ar1 position:danmuOnePosition new:newDanmuL];
    
    if (index != NSNotFound) {
        [ar1 replaceObjectAtIndex:index withObject:newDanmuL];
        completion(index, 0);
    }else {
        index = [self p_arDanmuLabel:ar2 position:danmuTwoPosition new:newDanmuL];
        
        if (index != NSNotFound) {
            [ar2 replaceObjectAtIndex:index withObject:newDanmuL];
            completion(index, newDanmuL.frame.size.height/2);
        }else {
            completion(NSNotFound, 0);
        }
    }
}

- (NSUInteger)p_arDanmuLabel:(NSMutableArray *)arDanmuLs position:(DanmuPositionStruct)danmuPosition new:(QHDanmuLabel *)newDanmuL {
    BOOL bFind = NO;
    NSUInteger index = danmuPosition.start;
    for (int i = (int)danmuPosition.start; i < danmuPosition.start + danmuPosition.length; i++) {
        id obj = [arDanmuLs objectAtIndex:i];
        index = i;
        if ([obj isKindOfClass:[QHDanmuLabel class]]) {
            QHDanmuLabel *lastDanmuL = obj;
            CGFloat durationTime = newDanmuL.startTime - lastDanmuL.startTime;
            bFind = (durationTime > (newDanmuL.animationDuartion - 1));
        }else {
            bFind = YES;
        }
        
        if (bFind)
            break;
    }
    if (!bFind) {
        if (index < danmuPosition.start + danmuPosition.length - 1)
            index += 1;
        else
            index = NSNotFound;
    }
    
    return index;
}

#pragma mark - Action

- (void)initStart {
    if (_danmuManagerState == DanmuManagerStateWait ||
        _danmuManagerState == DanmuManagerStateStop) {
        
        [self p_initData];
    }
}

- (void)rollDanmu:(NSTimeInterval)startTime {
    if (_danmuManagerState == DanmuManagerStateStop)
        return;
    dispatch_sync(self.danmuQueue, ^{
        if (_danmuManagerState != DanmuManagerStateAnimationing)
            _danmuManagerState = DanmuManagerStateAnimationing;
        
        if ((NSInteger)startTime % _durationTime == 0) {
            [self p_danmu:startTime];
        }
    });
}

- (void)stop {
    dispatch_sync(self.danmuQueue, ^{
        _danmuManagerState = DanmuManagerStateStop;
        [self.arRollChannelInfo removeAllObjects];
        [self.arFadeChannelInfo removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.danmuView.subviews makeObjectsPerformSelector:@selector(removeDanmu)];
            [self.danmuView removeFromSuperview];
        });
    });
}

- (void)pause {
    if (_danmuManagerState != DanmuManagerStateAnimationing)
        return;
    dispatch_sync(self.danmuQueue, ^{
        _danmuManagerState = DanmuManagerStatePause;
        [self.danmuView.subviews makeObjectsPerformSelector:@selector(pause)];
    });
}

- (void)resume:(NSTimeInterval)nowTime {
    if (_danmuManagerState != DanmuManagerStatePause)
        return;
    dispatch_sync(self.danmuQueue, ^{
        _danmuManagerState = DanmuManagerStateAnimationing;
        for (id subview in self.danmuView.subviews) {
            if ([subview isKindOfClass:[QHDanmuLabel class]]) {
                [(QHDanmuLabel *)subview resume:nowTime];
            }
        }
    });
}

- (void)restart {
    [self p_initData];
    dispatch_sync(self.danmuQueue, ^{
        _danmuManagerState = DanmuManagerStateAnimationing;
    });
}

- (void)insertDanmu:(NSDictionary *)info {
    dispatch_sync(self.danmuQueue, ^{
        __block QHDanmuLabel *danmuLabel = [QHDanmuLabel createWithInfo:info inView:self.danmuView];
        if ([danmuLabel isMoveModeFadeOut]) {
            [self p_getFadeBestChannel:danmuLabel completion:^(NSUInteger idx, CGFloat offsetY) {
                if (idx != NSNotFound) {
                    [danmuLabel setDanmuChannel:idx offset:offsetY];
                }
            }];
        }
        else {
            [self p_getRollBestChannel:danmuLabel completion:^(NSUInteger idx, CGFloat offsetX) {
                if (idx != NSNotFound) {
                    [danmuLabel setDanmuChannel:idx offset:offsetX];
                }
            }];
        }
    });
}

- (void)resetDanmuWithFrame:(CGRect)frame data:(NSArray *)infos inView:(UIView *)view durationTime:(NSUInteger)time {
    self.frame = frame;
    if (infos != nil)
        self.infos = [infos mutableCopy];
    self.superView = view;
    self.durationTime = time;
        
    [self p_initInfo];
}

- (void)resetDanmuWithFrame:(CGRect)frame {
    self.frame = frame;
    [self p_initInfo];
}

- (void)resetDanmuInfos:(NSArray *)infos {
    NSAssert(infos != nil, @"传入的弹幕信息不能为nil");
    self.infos = nil;
    self.infos = [infos mutableCopy];
}

@end
