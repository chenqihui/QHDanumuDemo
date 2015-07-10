//
//  QHDanmuView.m
//  QHDanumuDemo
//
//  Created by chen on 15/6/28.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuView.h"

@implementation QHDanmuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - Private

@end
