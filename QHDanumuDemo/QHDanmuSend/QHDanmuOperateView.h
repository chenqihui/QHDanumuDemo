//
//  QHDanmuOperateView.h
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QHDanmuOperateViewDelegate <NSObject>

- (void)closeDanmu:(UIButton *)btn;

@end

@interface QHDanmuOperateView : UIView

@property (nonatomic, strong, readonly) UITextField *editContentTF;

@property (nonatomic, strong, readonly) UIButton *sendBtn;

@property (nonatomic, weak) id<QHDanmuOperateViewDelegate> deleagte;

//- (void)setOperateHeight:(CGFloat)h;
//
//- (void)setEditHeight:(CGFloat)h;

@end
