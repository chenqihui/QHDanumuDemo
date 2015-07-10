//
//  QHDanmuSendView.h
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QHDanmuSendViewDelegate <NSObject>

- (void)sendDanmu:(NSString *)info;

@end

@interface QHDanmuSendView : UIView

@property (nonatomic, weak) id<QHDanmuSendViewDelegate> deleagte;

- (void)showAction:(UIView *)superView;

- (void)backAction;

@end
