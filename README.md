# GXCardView
卡片式布局(探探附近/QQ配对)，可以设置卡片堆叠效果，可以设置循环效果。
有建议可以联系QQ交流群:1101980843，喜欢就给个star哦，谢谢关注！
<p align="center">
<img src="https://github.com/gsyhei/GXCardView-Swift/blob/master/QQ.jpeg">
</p>

先上demo菜单效果
--
<p align="center">
<img src="https://github.com/gsyhei/GXCardView-Swift/blob/master/GXCardView-Swift.gif">
</p>

Requirements
--
<p align="left">
<a href="https://github.com/gsyhei/GXCardView-Swift"><img src="https://img.shields.io/badge/platform-ios%209.0-yellow.svg"></a>
<a href="https://github.com/gsyhei/GXCardView-Swift"><img src="https://img.shields.io/github/license/johnlui/Pitaya.svg?style=flat"></a>
<a href="https://github.com/gsyhei/GXCardView-Swift"><img src="https://img.shields.io/badge/language-Swift%204.2-orange.svg"></a>
</p>

Usage in you Podfile:
--

```
pod 'GXCardView'
```
* 其它版本 [Swift版本](https://github.com/gsyhei/GXCardView-Swift)
```
pod 'GXCardView-Swift'
```

GXCardViewDataSource
--

```objc
- (NSInteger)numberOfCountInCardView:(GXCardView *)cardView;

- (GXCardViewCell *)cardView:(GXCardView *)cardView cellForRowAtIndex:(NSInteger)index;
```

GXCardViewDelegate
--

```objc
- (void)cardView:(GXCardView *)cardView didRemoveCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index direction:(GXCardCellSwipeDirection)direction;

- (void)cardView:(GXCardView *)cardView didRemoveLastCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index;

- (void)cardView:(GXCardView *)cardView didDisplayCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index;

- (void)cardView:(GXCardView *)cardView didMoveCell:(GXCardViewCell *)cell forMovePoint:(CGPoint)point direction:(GXCardCellSwipeDirection)direction;
```

重载数据 
--

```objc
- (void)reloadData;
- (void)reloadDataAnimated:(BOOL)animated;
```

加载更多数据 
--

```objc
- (void)reloadMoreData;
- (void)reloadMoreDataAnimated:(BOOL)animated;
```

从index开始加载 
--

```objc
- (void)reloadDataFormIndex:(NSInteger)index;
- (void)reloadDataFormIndex:(NSInteger)index animated:(BOOL)animated;
```


可以设置参数
--

```objc
/** 卡片可见数量(默认3) */
@property (nonatomic, assign) NSInteger visibleCount;
/** 行间距(默认10.0，可自行计算scale比例来做间距) */
@property (nonatomic, assign) CGFloat lineSpacing;
/** 列间距(默认10.0，可自行计算scale比例来做间距) */
@property (nonatomic, assign) CGFloat interitemSpacing;
/** 侧滑最大角度(默认15°) */
@property (nonatomic, assign) CGFloat maxAngle;
/** 最大移除距离(默认屏幕的1/4) */
@property (nonatomic, assign) CGFloat maxRemoveDistance;
/** 是否重复(默认NO) */
@property (nonatomic, assign) BOOL isRepeat;
```

License
--
MIT


