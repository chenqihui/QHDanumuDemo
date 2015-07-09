//
//  ViewController.m
//  QHDanumuDemo
//
//  Created by chen on 15/6/28.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "ViewController.h"

#import "QHDanmuManager.h"
#import "QHDanmuSendView.h"

@interface ViewController () <QHDanmuSendViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *screenV;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval countTime;

@property (nonatomic, strong) QHDanmuManager *danmuManager;
@property (nonatomic, strong) QHDanmuSendView *danmuSendV;

@property (nonatomic) BOOL bPlaying;

@end

@implementation ViewController

- (void)dealloc {
    self.danmuManager = nil;
    self.danmuSendV = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.bPlaying = NO;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [[path stringByAppendingPathComponent:@"QHDanmuSource"] stringByAppendingPathExtension:@"plist"];
    NSArray *tempInfos = [NSArray arrayWithContentsOfFile:path];
    
    NSArray *infos = [tempInfos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGFloat v1 = [[obj1 objectForKey:kDanmuTimeKey] floatValue];
        CGFloat v2 = [[obj2 objectForKey:kDanmuTimeKey] floatValue];
        
        NSComparisonResult result = v1 <= v2 ? NSOrderedAscending : NSOrderedDescending;
        
        return result;
    }];
    tempInfos = nil;
//    NSLog(@"%@", infos);
    
    self.danmuManager = [[QHDanmuManager alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenV.bounds.size.height) data:infos inView:_screenV durationTime:1];
    
    self.countTime = -1;
    [self.danmuManager initStart];
}

//iOS8旋转动作的具体执行
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
         if ([QHDanmuUtil isOrientationLandscape]) {
             [self p_prepareFullScreen];
         }
         else {
             [self p_prepareSmallScreen];
         }
     } completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
         if (self.bPlaying)
             [self start:nil];
     }];
    
    [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
}

//iOS7旋转动作的具体执行
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        [self p_prepareFullScreen];
    }
    else {
        [self p_prepareSmallScreen];
    }
    if (self.bPlaying)
        [self start:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)p_destoryTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

// 切换成全屏的准备工作
- (void)p_prepareFullScreen {
    [self p_prepare];
}

// 切换成小屏的准备工作
- (void)p_prepareSmallScreen {
    [self p_prepare];
}

//由于这里大小屏无需区分，真正应用场景肯定是要区分的操作的
- (void)p_prepare {
    [self.danmuSendV backAction];
    [self p_destoryTimer];
    BOOL bPlaying = self.bPlaying;
    [self stop:nil];
    self.bPlaying = bPlaying;
    [self.danmuManager resetDanmuWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenV.bounds.size.height)];
}

#pragma mark - QHDanmuSendViewDelegate

- (void)sendDanmu:(NSString *)info {
    NSDate *now = [NSDate new];
    double t = ((double)now.timeIntervalSince1970);
    t = ((int)t)%1000;
    CGFloat nowTime = self.countTime + t*0.0001;
    [self.danmuManager insertDanmu:@{kDanmuContentKey:info, kDanmuTimeKey:@(nowTime), kDanmuOptionalKey:@"df"}];
    
    if (self.bPlaying)
        [self resume:nil];
}

#pragma mark - Action

- (IBAction)start:(id)sender {
    [self.danmuManager initStart];
    self.bPlaying = YES;
    
    if ([_timer isValid]) {
        return;
    }
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressVideo) userInfo:nil repeats:YES];
    }
}

- (IBAction)stop:(id)sender {
    self.bPlaying = NO;
    [self.danmuManager stop];
}

- (IBAction)pause:(id)sender {
    [self p_destoryTimer];
    [self.danmuManager pause];
}

- (IBAction)resume:(id)sender {
    [self.danmuManager resume:_countTime];
    
    [self start:nil];
}

- (IBAction)restart:(id)sender {
    self.countTime = -1;
    [self.danmuManager restart];
    [self p_destoryTimer];

    [self start:nil];
}

- (IBAction)send:(id)sender {
    if (self.danmuSendV != nil) {
        self.danmuSendV = nil;
    }
    self.danmuSendV = [[QHDanmuSendView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.danmuSendV];
    self.danmuSendV.deleagte = self;
    [self.danmuSendV showAction:self.view];
    
    if (self.bPlaying)
        [self pause:nil];
}

- (void)progressVideo {
    self.countTime++;
    [_danmuManager rollDanmu:_countTime];
}

- (IBAction)clickScreenView:(id)sender {
    NSLog(@"hello world");
}

#pragma mark - Get

- (void)setCountTime:(NSTimeInterval)countTime {
    _countTime = countTime;
    self.playTimeLabel.text = [NSString stringWithFormat:@"%f", _countTime];
}

@end
