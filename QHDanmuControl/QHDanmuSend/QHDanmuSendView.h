//
//  QHDanmuSendView.h
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHDanmuSendView;

@protocol QHDanmuSendViewDelegate <NSObject>

@optional

- (void)sendDanmu:(QHDanmuSendView *)danmuSendV info:(NSString *)info;

- (void)closeSendDanmu:(QHDanmuSendView *)danmuSendV;

@end

@interface QHDanmuSendView : UIView

@property (nonatomic, weak) id<QHDanmuSendViewDelegate> deleagte;

- (void)showAction:(UIView *)superView;

- (void)backAction;

@end
