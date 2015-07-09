//
//  QHDanmuOperateView.m
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuOperateView.h"

@interface QHDanmuOperateView () {
    CGFloat _spaceY;
    CGFloat _spaceX;
}

@property (nonatomic, strong, readwrite) UITextField *editContentTF;

@property (nonatomic, strong, readwrite) UIButton *sendBtn;

@end

@implementation QHDanmuOperateView

- (void)dealloc {
    self.editContentTF = nil;
    self.sendBtn = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Private

- (void)setup {
    self.backgroundColor = [UIColor lightGrayColor];
    self.userInteractionEnabled = YES;
    [self p_setupData];
    [self p_addView];
}

- (void)p_setupData {
    _spaceX = 5;
    _spaceY = 5;
}

- (void)p_addView {
    CGFloat btnH = self.frame.size.height - 2*_spaceY;
    CGFloat btnW = btnH;
    UIFont *font = [UIFont systemFontOfSize:15];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(self.frame.size.width - btnH - _spaceX, _spaceY, btnW, btnH);
    self.sendBtn.layer.cornerRadius = 3;
    self.sendBtn.backgroundColor = [UIColor blueColor];
    [self.sendBtn.titleLabel setFont:font];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [self addSubview:self.sendBtn];
    [self.sendBtn addTarget:self action:@selector(closeDanmuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.editContentTF = [[UITextField alloc] initWithFrame:CGRectMake(_spaceX, _spaceY, CGRectGetMinX(self.sendBtn.frame) - 2*_spaceX, btnH)];
    self.editContentTF.layer.cornerRadius = 3;
    self.editContentTF.backgroundColor = [UIColor whiteColor];
    self.editContentTF.font = font;
    self.editContentTF.returnKeyType = UIReturnKeySend;
    self.editContentTF.layer.borderWidth = 1;
    self.editContentTF.layer.borderColor = [UIColor orangeColor].CGColor;
    self.editContentTF.placeholder = @"请输入弹幕内容";
    [self addSubview:self.editContentTF];
}

#pragma mark - Action

- (void)closeDanmuAction:(UIButton *)btn {
    if ([self.deleagte respondsToSelector:@selector(closeDanmu:)]) {
        [self.deleagte closeDanmu:btn];
    }
}

@end
