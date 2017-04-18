# 说明：

QHDanmu文件夹下是主要的弹幕模块系统

QHDanmuSend文件夹下是简单的发射弹幕的界面

使用可以参考ViewController

创建弹幕

self.danmuManager = [[QHDanmuManager alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _screenV.bounds.size.height) data:infos inView:_screenV durationTime:1];

[self.danmuManager initStart];

发射弹幕

self.danmuSendV = [[QHDanmuSendView alloc] initWithFrame:self.view.bounds];

[self.view addSubview:self.danmuSendV];

self.danmuSendV.deleagte = self;
 
[self.danmuSendV showAction:self.view];

# 安装（通过CocoaPods）：

pod "QHDanumuDemo", '~> 1.4'

pod "QHDanumuDemo", '~> 1.3'

# 效果图：

![image](https://github.com/chenqihui/QHDanumuDemo/blob/master/screenshots/QHDanmuShow.gif)

# 描述：

一、固定的数值（可自行修改）：

1、字体大小                     大中小分别为19、17、15

2、航道高度                     高度为25

3、航道缓冲区宽度                宽度为120

4、航行总时间                   时间为5秒

5、当需要第2种航道选择时的间隔距离  距离为20


二、滑动航道选择

方案：

1、

通过弹幕碰撞检测，决定是否使用此航道，即航道每次都是从上往下做判断。

碰撞检测主要难点在于检测横向滚动弹幕之间的碰撞，弹幕存活时间由其显示时间和存活长短决定，因此，弹幕之间是否碰撞只需检测开始和消失是否碰撞即可。

这个参考[iOS弹幕(源码)实现原理解析](http://www.olinone.com/?p=186)

2、

当第一个找不到航道时候，检查所有航道最小距离，这个距离必须在指定的最大弹幕的长度之内，如果找到，将其放置在对于弹幕后面。

2.1、前弹幕最右边还没出现在屏幕时，新弹幕放置到其后面，space为俩之间间隔

2.2、前弹幕最右边已出现在屏幕时，新弹幕仍然放置边界等待滚动

浮现航道选择（分为两排航道）

方案：

1、

选择第一排，按没有弹幕为准，没有就显示

2、

第一排都占满，使用第二排，第二排是在第一排的基础坐标y向下半个航道高度，

这样可以有个视觉差，第一排显示消失时，可以看到第二排，从而争取更大的显示航道（2n－1）


三、其他

1、弹幕字体大小、颜色和运动模式都是随机的。

2、支持横竖屏
