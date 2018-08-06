//
//  GXCardView.m
//  GXCardViewDemo
//
//  Created by Gin on 2018/7/31.
//  Copyright © 2018年 gin. All rights reserved.
//

#import "GXCardView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define GX_SNAPSHOTVIEW_TAG           999
#define GX_DEGREES_TO_RADIANS(angle)  (angle / 180.0 * M_PI)

static CGFloat const GX_DefaultDuration    = 0.25f;
static CGFloat const GX_SpringDuration     = 0.5f;
static CGFloat const GX_SpringWithDamping  = 0.5f;
static CGFloat const GX_SpringVelocity     = 0.8f;

@class GXCardViewCell;
@protocol GXCardViewCellDelagate <NSObject>
@optional
- (void)cardViewCellDidRemoveFromSuperView:(GXCardViewCell *)cell;
- (void)cardViewCellDidMoveFromSuperView:(GXCardViewCell*)cell forMovePoint:(CGPoint)point;
@end

@interface GXCardViewCell()
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, assign) CGFloat maxAngle;
@property (nonatomic, assign) CGFloat maxRemoveDistance;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic,   weak) id<GXCardViewCellDelagate> delegate;

- (void)addCellSnapshotView;
- (void)removeCellSnapshotView;

@end

@implementation GXCardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self setupView];
    }
    return self;
}

- (void)addCellSnapshotView {
    [self removeCellSnapshotView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
    snapshotView.tag = GX_SNAPSHOTVIEW_TAG;
    snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:snapshotView];
    [self bringSubviewToFront:snapshotView];
}

- (void)removeCellSnapshotView {
    UIView *snapshotView = [self viewWithTag:GX_SNAPSHOTVIEW_TAG];
    if (snapshotView) {
        [snapshotView removeFromSuperview];
    }
}

- (void)setupView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
    }
    self.contentView.clipsToBounds = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:pan];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.currentPoint = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint movePoint = [pan translationInView:pan.view];
            self.currentPoint = CGPointMake(self.currentPoint.x + movePoint.x , self.currentPoint.y + movePoint.y);
            
            CGFloat moveScale = self.currentPoint.x / self.maxRemoveDistance;
            if (ABS(moveScale) > 1.0) {
                moveScale = (moveScale > 0) ? 1.0 : -1.0;
            }
            CGFloat angle = GX_DEGREES_TO_RADIANS(self.maxAngle) * moveScale;
            CGAffineTransform transRotation = CGAffineTransformMakeRotation(angle);
            self.transform = CGAffineTransformTranslate(transRotation, self.currentPoint.x, self.currentPoint.y);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewCellDidMoveFromSuperView:forMovePoint:)]) {
                [self.delegate cardViewCellDidMoveFromSuperView:self forMovePoint:self.currentPoint];
            }
            [pan setTranslation:CGPointZero inView:pan.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self didPanStateEnded];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
             [self restoreCellLocation];
            break;
        default:
            break;
    }
}

// 手势结束操作（不考虑上下位移）
- (void)didPanStateEnded {
    // 右滑移除
    if (self.currentPoint.x > self.maxRemoveDistance) {
        __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
        snapshotView.frame = self.frame;
        snapshotView.transform = self.transform;
        [self.superview.superview addSubview:snapshotView];
        [self didCellRemoveFromSuperview];

        CGFloat endCenterX = SCREEN_WIDTH/2 + self.frame.size.width * 1.5;
        [UIView animateWithDuration:GX_DefaultDuration animations:^{
            CGPoint center = self.center;
            center.x = endCenterX;
            snapshotView.center = center;
        } completion:^(BOOL finished) {
            [snapshotView removeFromSuperview];
        }];
    }
    // 左滑移除
    else if (self.currentPoint.x < -self.maxRemoveDistance) {
        __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
        snapshotView.frame = self.frame;
        snapshotView.transform = self.transform;
        [self.superview.superview addSubview:snapshotView];
        [self didCellRemoveFromSuperview];

        CGFloat endCenterX = -(SCREEN_WIDTH/2 + self.frame.size.width);
        [UIView animateWithDuration:GX_DefaultDuration animations:^{
            CGPoint center = self.center;
            center.x = endCenterX;
            snapshotView.center = center;
        } completion:^(BOOL finished) {
            [snapshotView removeFromSuperview];
        }];
    }
    // 滑动距离不够归位
    else {
        [self restoreCellLocation];
    }
}

// 还原卡片位置
- (void)restoreCellLocation {
    [UIView animateWithDuration:GX_SpringDuration delay:0
         usingSpringWithDamping:GX_SpringWithDamping
          initialSpringVelocity:GX_SpringVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                     } completion:NULL];
}

// 卡片移除处理
- (void)didCellRemoveFromSuperview {
    self.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(cardViewCellDidRemoveFromSuperView:)]) {
        [self.delegate cardViewCellDidRemoveFromSuperView:self];
    }
}

- (void)removeFromSuperviewSwipe:(GXCardCellSwipeDirection)direction {
    switch (direction) {
        case GXCardCellSwipeDirectionLeft: {
            [self removeFromSuperviewLeft];
        }
            break;
        case GXCardCellSwipeDirectionRight: {
            [self removeFromSuperviewRight];
        }
            break;
        default:
            break;
    }
}

// 向左边移除动画
- (void)removeFromSuperviewLeft {
    __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
    [self.superview.superview addSubview:snapshotView];
    [self didCellRemoveFromSuperview];

    CGAffineTransform transRotation = CGAffineTransformMakeRotation(-GX_DEGREES_TO_RADIANS(self.maxAngle));
    CGAffineTransform transform = CGAffineTransformTranslate(transRotation, 0, self.frame.size.height/4.0);
    CGFloat endCenterX = -(SCREEN_WIDTH/2 + self.frame.size.width);
    [UIView animateWithDuration:GX_DefaultDuration animations:^{
        CGPoint center = self.center;
        center.x = endCenterX;
        snapshotView.center = center;
        snapshotView.transform = transform;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
    }];
}

// 向右边移除动画
- (void)removeFromSuperviewRight {
    __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
    snapshotView.frame = self.frame;
    [self.superview.superview addSubview:snapshotView];
    [self didCellRemoveFromSuperview];
    
    CGAffineTransform transRotation = CGAffineTransformMakeRotation(GX_DEGREES_TO_RADIANS(self.maxAngle));
    CGAffineTransform transform = CGAffineTransformTranslate(transRotation, 0, self.frame.size.height/4.0);
    CGFloat endCenterX = SCREEN_WIDTH/2 + self.frame.size.width * 1.5;
    [UIView animateWithDuration:GX_DefaultDuration animations:^{
        CGPoint center = self.center;
        center.x = endCenterX;
        snapshotView.center = center;
        snapshotView.transform = transform;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
    }];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GXCardView()<GXCardViewCellDelagate>
/** cell容器 */
@property (nonatomic, strong) UIView *containerView;
/** 注册cell相关 */
@property (nonatomic, strong) UINib *nib;
@property (nonatomic,   copy) Class cellClass;
@property (nonatomic,   copy) NSString *identifier;
/** 当前索引(已显示的最大索引) */
@property (nonatomic, assign) NSInteger currentIndex;
/** 当前可视cells */
@property (nonatomic, strong) NSArray<__kindof GXCardViewCell *> *visibleCells;
/** 重用卡片数组  */
@property (nonatomic, strong) NSMutableArray<__kindof GXCardViewCell *> *reusableCells;

@end

@implementation GXCardView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configCardView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configCardView];
    }
    return self;
}

- (void)configCardView {
    _visibleCount      = 3;
    _lineSpacing       = 10.0;
    _interitemSpacing  = 10.0;
    _maxAngle          = 15;
    _maxRemoveDistance = SCREEN_WIDTH / 4.0;
    _reusableCells     = [NSMutableArray array];
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (void)reloadData {
    [self reloadDataAnimated:NO];
}

- (void)reloadDataAnimated:(BOOL)animated {
    self.currentIndex = 0;
    [self.reusableCells removeAllObjects];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger maxCount = [self.dataSource numberOfCountInCardView:self];
    NSInteger showNumber = MIN(maxCount, self.visibleCount);
    for (int i = 0; i < showNumber; i++) {
        [self createCardViewCellWithIndex:i];
    }
    [self updateLayoutVisibleCellsWithAnimated:animated];
}

/** 创建新的cell */
- (void)createCardViewCellWithIndex:(NSInteger)index {
    GXCardViewCell *cell = [self.dataSource cardView:self cellForRowAtIndex:index];
    cell.maxRemoveDistance = self.maxRemoveDistance;
    cell.maxAngle = self.maxAngle;
    cell.delegate = self;

    NSInteger showIndex = self.visibleCount - 1;
    CGFloat x = self.lineSpacing * showIndex;
    CGFloat y = self.interitemSpacing  * showIndex;
    CGFloat width = self.frame.size.width - self.lineSpacing * 2 * showIndex;
    CGFloat height = self.frame.size.height - self.interitemSpacing * showIndex;
    // 添加最大frame也就是最上层时候的Cell快照
    // 解释下：快照是为了保证scale动画的时候Cell内容不乱/动画更自然
    cell.frame = CGRectMake(0, 0, self.frame.size.width, height);
    [cell addCellSnapshotView];
    // 重设为初始frame
    cell.frame = CGRectMake(x, y, width, height);
    cell.userInteractionEnabled = NO;
    [self.containerView insertSubview:cell atIndex:0];

    self.currentIndex = index;
}

/** 更新布局（动画） */
- (void)updateLayoutVisibleCellsWithAnimated:(BOOL)animated {
    CGFloat height = self.frame.size.height - self.interitemSpacing * (self.visibleCount - 1);
    NSInteger count = self.visibleCells.count;
    for (NSInteger i = 0; i < count; i ++) {
        // 计算出最终效果的frame
        NSInteger showIndex = count - i - 1;
        CGFloat x = self.lineSpacing * showIndex;
        CGFloat y = self.interitemSpacing  * showIndex;
        CGFloat width = self.frame.size.width - 2 * self.lineSpacing * showIndex;
        CGRect newFrame = CGRectMake(x, y, width, height);
        // 获取当前要显示的的cells
        GXCardViewCell *cell = self.visibleCells[i];
        // 显示的最后一个为最上层的cell
        BOOL isLast = (i == (count - 1));
        if (isLast) {
            cell.userInteractionEnabled = YES;
            if ([self.delegate respondsToSelector:@selector(cardView:didDisplayCell:forRowAtIndex:)]) {
                [self.delegate cardView:self didDisplayCell:cell forRowAtIndex:(self.currentIndex-i)];
            }
        }
        if (animated) {
            [self updateConstraintsCell:cell frame:newFrame isLast:isLast];
        } else {
            cell.frame = newFrame;
        }
    }
}

- (void)updateConstraintsCell:(GXCardViewCell*)cell frame:(CGRect)frame isLast:(BOOL)isLast {
    [UIView animateWithDuration:GX_DefaultDuration animations:^{
        cell.frame = frame;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (isLast) {
            [cell removeCellSnapshotView];
        }
    }];
}

/** 当前最上层索引 */
- (NSInteger)currentFirstIndex {
    return self.currentIndex - self.visibleCells.count + 1;
}

/** 可视cells */
- (NSArray<GXCardViewCell *> *)visibleCells {
    return self.containerView.subviews;
}

/** 注册cell */
- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    self.nib = nib;
    self.identifier = identifier;
}
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    self.cellClass = cellClass;
    self.identifier = identifier;
}

/** 获取缓存cell */
- (__kindof GXCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    for (GXCardViewCell *cell in self.reusableCells) {
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            [self.reusableCells removeObject:cell];
            
            return cell;
        }
    }
    if (self.nib) {
        GXCardViewCell *cell = [[self.nib instantiateWithOwner:nil options:nil] lastObject];
        cell.reuseIdentifier = identifier;
        
        return cell;
    } else if (self.cellClass) { // 注册class
        GXCardViewCell *cell = [[self.cellClass alloc] initWithReuseIdentifier:identifier];
        cell.reuseIdentifier = identifier;
        
        return cell;
    }
    return nil;
}

/** 获取index对应的cell */
- (nullable __kindof GXCardViewCell *)cellForRowAtIndex:(NSInteger)index {
    NSInteger visibleIndex = index - self.currentIndex;
    GXCardViewCell *cell = [self.visibleCells objectAtIndex:visibleIndex];
    
    return cell;
}

/** 获取cell对应的index */
- (NSInteger)indexForCell:(GXCardViewCell *)cell {
    NSInteger visibleIndex = [self.visibleCells indexOfObject:cell];
    
    return (self.currentIndex - visibleIndex);
}

/** 移除最上层cell */
- (void)removeTopCardViewFromSwipe:(GXCardCellSwipeDirection)direction {
    if(self.visibleCells.count == 0) return;
    GXCardViewCell *topcell = [self.visibleCells lastObject];
    [topcell removeFromSuperviewSwipe:direction];
}

#pragma mark - GXCardViewCellDelagate

- (void)cardViewCellDidRemoveFromSuperView:(GXCardViewCell *)cell {
    // 当cell被移除时重新刷新视图
    [self.reusableCells addObject:cell];
    
    // 通知代理 移除了当前cell
    if ([self.delegate respondsToSelector:@selector(cardView:didRemoveCell:forRowAtIndex:)]) {
        [self.delegate cardView:self didRemoveCell:cell forRowAtIndex:self.currentFirstIndex];
    }

    NSInteger count = [self.dataSource numberOfCountInCardView:self];
    // 移除后的卡片是最后一张(没有更多)
    if(self.visibleCells.count == 0) { // 只有最后一张卡片的时候
        if ([self.delegate respondsToSelector:@selector(cardView:didRemoveLastCell:forRowAtIndex:)]) {
            [self.delegate cardView:self didRemoveLastCell:cell forRowAtIndex:self.currentIndex];
        }
        return;
    }
    // 当前数据源还有数据 继续创建cell
    if (self.currentIndex < count - 1) {
        [self createCardViewCellWithIndex:(self.currentIndex + 1)];
    }
    // 更新布局
    [self updateLayoutVisibleCellsWithAnimated:YES];
}

- (void)cardViewCellDidMoveFromSuperView:(GXCardViewCell *)cell forMovePoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(cardView:didMoveCell:forMovePoint:)]) {
        [self.delegate cardView:self didMoveCell:cell forMovePoint:point];
    }
}

@end
