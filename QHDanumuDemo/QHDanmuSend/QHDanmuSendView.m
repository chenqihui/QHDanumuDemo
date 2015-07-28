//
//  QHDanmuSendView.m
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuSendView.h"

#import "QHDanmuOperateView.h"

#define VIEW_OPERATE_HEIGHT    44

@interface QHDanmuSendView () <QHDanmuOperateViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) QHDanmuOperateView *danmuOperateV;
@property (nonatomic, strong) UIControl *blackOverlay;

@end

@implementation QHDanmuSendView

- (void)dealloc {
    [self removeKeyboardNotificationCenter];
    self.danmuOperateV = nil;
    self.blackOverlay = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Do any additional setup after loading the view.
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        [self addSubview:self.blackOverlay];
        
        self.danmuOperateV = [[QHDanmuOperateView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - VIEW_OPERATE_HEIGHT, self.frame.size.width, VIEW_OPERATE_HEIGHT)];
        self.danmuOperateV.deleagte = self;
        self.danmuOperateV.editContentTF.delegate = self;
        [self addSubview:self.danmuOperateV];
        
        [self addKeyboardNotificationCenter];
        
        self.alpha = 0;
    }
    return self;
}

#pragma mark - Private

//重设界面布局
- (void)p_setOperateView:(CGFloat)h {
    CGFloat top = h - CGRectGetHeight(self.danmuOperateV.frame);
    CGRect frame = self.danmuOperateV.frame;
    frame.origin.y = top;
    self.danmuOperateV.frame = frame;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.deleagte respondsToSelector:@selector(sendDanmu:info:)]) {
        [self.deleagte sendDanmu:self info:textField.text];
    }
    [self backAction];
    return NO;
}

#pragma mark - QHDanmuOperateViewDelegate

- (void)closeDanmu:(UIButton *)btn {
    [self backAction];
}

#pragma mark - Action

- (void)showAction:(UIView *)superView {
    self.alpha = 1;
    CGRect frame = self.frame;
    frame.origin.y = superView.frame.size.height;
    self.frame = frame;
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superView.frame.size.height - self.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self.danmuOperateV.editContentTF becomeFirstResponder];
    }];
}

- (void)backAction {
    [self.danmuOperateV.editContentTF resignFirstResponder];
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.superview.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        if ([self.deleagte respondsToSelector:@selector(closeSendDanmu:)]) {
            [self.deleagte closeSendDanmu:self];
        }
        [self removeFromSuperview];
    }];
}

#pragma mark keyboardaction

- (void)addKeyboardNotificationCenter {
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotificationCenter {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardAction:(NSNotification *)notification complete:(void(^)(CGFloat hKeyB))complete {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationCurveObject =[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    NSValue *animationDurationObject =[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject =[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0,0, 0, 0);
    [animationCurveObject getValue:&animationCurve];
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    CGFloat hKeyB = 0;
    hKeyB = keyboardEndRect.size.height;
    
    [UIView beginAnimations:@"keyboardAction" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    complete(hKeyB);
    [UIView commitAnimations];
}

#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    [self keyboardAction:notification complete:^(CGFloat hKeyB) {
        [self p_setOperateView:self.frame.size.height - hKeyB];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self keyboardAction:notification complete:^(CGFloat hKeyB) {
        [self p_setOperateView:self.frame.size.height];
    }];
}

#pragma mark - Get

- (UIControl *)blackOverlay {
    if (_blackOverlay == nil) {
        _blackOverlay = [[UIControl alloc] initWithFrame:self.bounds];
        _blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIColor *maskColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _blackOverlay.backgroundColor = maskColor;
    }
    
    return _blackOverlay;
}

@end
