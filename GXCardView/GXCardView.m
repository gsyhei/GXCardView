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
#define GX_DEGREES_TO_RADIANS(angle)  (angle / 180.0 * M_PI)

static CGFloat const GX_DefaultDuration    = 0.25f;
static CGFloat const GX_SpringDuration     = 0.5f;
static CGFloat const GX_SpringWithDamping  = 0.5f;
static CGFloat const GX_SpringVelocity     = 0.8f;

@class GXCardViewCell;
@protocol GXCardViewCellDelagate <NSObject>
@optional
- (void)cardViewCellDidRemoveFromSuperView:(GXCardViewCell *)cell withDirection:(GXCardCellSwipeDirection)direction;
- (void)cardViewCellDidMoveFromSuperView:(GXCardViewCell*)cell forMovePoint:(CGPoint)point;
@end

@interface GXCardViewCell()
@property (nonatomic, assign) CGFloat maxAngle;
@property (nonatomic, assign) CGFloat maxRemoveDistance;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic,   weak) id<GXCardViewCellDelagate> cell_delegate;

@end

@implementation GXCardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self setupView];
    }
    return self;
}

- (void)setupView {
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
            
            if (self.cell_delegate && [self.cell_delegate respondsToSelector:@selector(cardViewCellDidMoveFromSuperView:forMovePoint:)]) {
                [self.cell_delegate cardViewCellDidMoveFromSuperView:self forMovePoint:self.currentPoint];
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
        __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
        snapshotView.transform = self.transform;
        [self.superview.superview addSubview:snapshotView];
        [self didCellRemoveFromSuperviewWithDirection:GXCardCellSwipeDirectionRight];
        
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
        __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
        snapshotView.transform = self.transform;
        [self.superview.superview addSubview:snapshotView];
        [self didCellRemoveFromSuperviewWithDirection:GXCardCellSwipeDirectionLeft];
        
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
- (void)didCellRemoveFromSuperviewWithDirection:(GXCardCellSwipeDirection)direction {
    self.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];
    if ([self.cell_delegate respondsToSelector:@selector(cardViewCellDidRemoveFromSuperView:withDirection:)]) {
        [self.cell_delegate cardViewCellDidRemoveFromSuperView:self withDirection:direction];
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
    __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
    [self.superview.superview addSubview:snapshotView];
    [self didCellRemoveFromSuperviewWithDirection:GXCardCellSwipeDirectionLeft];
    
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
    __block UIView *snapshotView = [self snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = self.frame;
    [self.superview.superview addSubview:snapshotView];
    [self didCellRemoveFromSuperviewWithDirection:GXCardCellSwipeDirectionRight];
    
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
    _isRepeat          = NO;
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
    maxCount = self.isRepeat ? (maxCount + self.visibleCount - 1) : maxCount;
    NSInteger showNumber = MIN(maxCount, self.visibleCount);
    for (int i = 0; i < showNumber; i++) {
        [self createCardViewCellWithIndex:i];
    }
    [self updateLayoutVisibleCellsWithAnimated:animated];
}

- (void)reloadDataRepeatAnimated:(BOOL)animated {
    self.currentIndex = 0;
    [self.reusableCells removeAllObjects];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger maxCount = [self.dataSource numberOfCountInCardView:self];
    maxCount = self.isRepeat ? (maxCount + self.visibleCount - 1) : maxCount;
    NSInteger showNumber = MIN(maxCount, self.visibleCount);
    for (int i = 0; i < showNumber; i++) {
        [self createRepeatCardViewCellWithIndex:i];
    }
    [self updateLayoutVisibleCellsWithAnimated:animated];
}

- (void)reloadMoreData {
    [self reloadMoreDataAnimated:NO];
}

- (void)reloadMoreDataAnimated:(BOOL)animated {
    NSAssert(!self.isRepeat, @"isRepeat为YES不允许加载更多数据！");
    [self.reusableCells removeAllObjects];
    NSInteger loadMoreCount = self.visibleCount - self.visibleCells.count;
    NSInteger loadMaxLength = self.currentIndex + loadMoreCount;
    for (NSInteger i = self.currentIndex + 1; i < loadMaxLength; i++) {
        [self createCardViewCellWithIndex:i];
    }
    [self updateLayoutVisibleCellsWithAnimated:animated];
}

- (void)reloadDataFormIndex:(NSInteger)index {
    [self reloadDataFormIndex:index animated:NO];
}

- (void)reloadDataFormIndex:(NSInteger)index animated:(BOOL)animated {
    NSAssert(!self.isRepeat, @"isRepeat为YES不允许从索引处加载！");
    NSInteger maxCount = [self.dataSource numberOfCountInCardView:self];
    NSAssert(index < maxCount, @"index不能大于等于cell的数量！");
    
    [self.reusableCells removeAllObjects];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger loadMaxLength = index + self.visibleCount;
    loadMaxLength = MIN(loadMaxLength, maxCount);
    for (NSInteger i = index; i < loadMaxLength; i++) {
        [self createCardViewCellWithIndex:i];
    }
    [self updateLayoutVisibleCellsWithAnimated:animated];
}

/** 创建新的cell */
- (void)createCardViewCellWithIndex:(NSInteger)index {
    GXCardViewCell *cell = [self.dataSource cardView:self cellForRowAtIndex:index];
    cell.index = index;
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    cell.maxRemoveDistance = self.maxRemoveDistance;
    cell.maxAngle = self.maxAngle;
    cell.cell_delegate = self;
    cell.userInteractionEnabled = NO;
    NSInteger showCount = self.visibleCount - 1;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - (showCount * self.interitemSpacing);
    cell.frame = CGRectMake(0, 0, width, height);
    [self.containerView insertSubview:cell atIndex:0];
    [self.containerView layoutIfNeeded];
    self.currentIndex = index;
    
    CGFloat minWidth = self.frame.size.width - 2 * self.lineSpacing * showCount;
    CGFloat minHeight = self.frame.size.height - 2 * self.interitemSpacing * showCount;
    CGFloat minWScale = minWidth / self.frame.size.width;
    CGFloat minHScale = minHeight / self.frame.size.height;
    CGFloat yOffset = (self.interitemSpacing / minHScale) * 2 *showCount;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(minWScale, minHScale);
    CGAffineTransform transform = CGAffineTransformTranslate(scaleTransform, 0, yOffset);
    cell.transform = transform;
}

/** repeat为YES创建新的cell */
- (void)createRepeatCardViewCellWithIndex:(NSInteger)index {
    GXCardViewCell *cell = [self.dataSource cardView:self cellForRowAtIndex:index];
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    cell.maxRemoveDistance = self.maxRemoveDistance;
    cell.maxAngle = self.maxAngle;
    cell.cell_delegate = self;
    cell.userInteractionEnabled = NO;
    NSInteger showCount = self.visibleCount;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - (showCount * self.interitemSpacing);
    cell.frame = CGRectMake(0, 0, width, height);
    [self.containerView insertSubview:cell atIndex:0];
    [self.containerView layoutIfNeeded];
    self.currentIndex = index;
    
    CGFloat minWidth = self.frame.size.width - 2 * self.lineSpacing * showCount;
    CGFloat minHeight = self.frame.size.height - 2 * self.interitemSpacing * showCount;
    CGFloat minWScale = minWidth / self.frame.size.width;
    CGFloat minHScale = minHeight / self.frame.size.height;
    CGFloat yOffset = (self.interitemSpacing / minHScale) * 2 *showCount;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(minWScale, minHScale);
    CGAffineTransform transform = CGAffineTransformTranslate(scaleTransform, 0, yOffset);
    cell.transform = transform;
}

/** 更新布局（动画） */
- (void)updateLayoutVisibleCellsWithAnimated:(BOOL)animated {
    NSInteger showCount = self.visibleCount - 1;
    CGFloat minWidth = self.frame.size.width - 2 * self.lineSpacing * showCount;
    CGFloat minHeight = self.frame.size.height - 2 * self.interitemSpacing * showCount;
    CGFloat minWScale = minWidth / self.frame.size.width;
    CGFloat minHScale = minHeight / self.frame.size.height;
    CGFloat itemWScale = (1.0 - minWScale) / showCount;
    CGFloat itemHScale = (1.0 - minHScale) / showCount;
    NSInteger count = self.visibleCells.count;
    for (NSInteger i = 0; i < count; i ++) {
        // 计算出最终效果的transform
        NSInteger showIndex = count - i - 1;
        CGFloat wScale = 1.0 - showIndex * itemWScale;
        CGFloat hScale = 1.0 - showIndex * itemHScale;
        CGFloat y = (self.interitemSpacing / hScale) * 2 * showIndex;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(wScale, hScale);
        CGAffineTransform transform = CGAffineTransformTranslate(scaleTransform, 0, y);
        // 获取当前要显示的的cells
        GXCardViewCell *cell = self.visibleCells[i];
        // 判断是不是当前显示的最后一个(最上层显示)
        BOOL isLast = (i == (count - 1));
        if (isLast) {
            cell.userInteractionEnabled = YES;
            if ([self.delegate respondsToSelector:@selector(cardView:didDisplayCell:forRowAtIndex:)]) {
                [self.delegate cardView:self didDisplayCell:cell forRowAtIndex:cell.index];
            }
        }
        if (animated) {
            [self updateConstraintsCell:cell transform:transform];
        } else {
            cell.transform = transform;
        }
    }
}

- (void)updateConstraintsCell:(GXCardViewCell*)cell transform:(CGAffineTransform)transform {
    [UIView animateWithDuration:GX_DefaultDuration animations:^{
        cell.transform = transform;
    } completion:NULL];
}

/** 当前最上层索引 */
- (NSInteger)currentFirstIndex {
    NSInteger index = self.currentIndex - self.visibleCells.count + 1;
    if (self.isRepeat) {
        if (index < 0) {
            index = index + [self.dataSource numberOfCountInCardView:self];
        }
    }
    return index;
}

/** 数据源索引转换为对应的显示索引 */
- (NSInteger)visibleIndexAtIndex:(NSInteger)index {
    if (self.isRepeat) {
        if (index < self.currentFirstIndex) {
            return index + [self.dataSource numberOfCountInCardView:self] - self.currentFirstIndex;
        }
    }
    NSInteger visibleIndex = index - self.currentFirstIndex;
    return visibleIndex;
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
    NSLog(@"请先注册cardCell!");
    return nil;
}

/** 获取index对应的cell */
- (nullable __kindof GXCardViewCell *)cellForRowAtIndex:(NSInteger)index {
    NSInteger visibleIndex = [self visibleIndexAtIndex:index];
    if (visibleIndex >= 0 && visibleIndex < self.visibleCells.count) {
        GXCardViewCell *cell = [self.visibleCells objectAtIndex:visibleIndex];
        return cell;
    }
    return nil;
}

/** 获取cell对应的index */
- (NSInteger)indexForCell:(GXCardViewCell *)cell {
    return cell.index;
}

/** 移除最上层cell */
- (void)removeTopCardViewFromSwipe:(GXCardCellSwipeDirection)direction {
    if(self.visibleCells.count == 0) return;
    GXCardViewCell *topcell = [self.visibleCells lastObject];
    [topcell removeFromSuperviewSwipe:direction];
}

#pragma mark - GXCardViewCellDelagate

- (void)cardViewCellDidRemoveFromSuperView:(GXCardViewCell *)cell withDirection:(GXCardCellSwipeDirection)direction {
    // 当cell被移除时重新刷新视图
    [self.reusableCells addObject:cell];
    
    // 通知代理 移除了当前cell
    if ([self.delegate respondsToSelector:@selector(cardView:didRemoveCell:forRowAtIndex:direction:)]) {
        [self.delegate cardView:self didRemoveCell:cell forRowAtIndex:cell.index direction:direction];
    }
    
    NSInteger count = [self.dataSource numberOfCountInCardView:self];
    // 移除后的卡片是最后一张(没有更多)
    if(self.visibleCells.count == 0) { // 只有最后一张卡片的时候
        if ([self.delegate respondsToSelector:@selector(cardView:didRemoveLastCell:forRowAtIndex:)]) {
            [self.delegate cardView:self didRemoveLastCell:cell forRowAtIndex:cell.index];
        }
        return;
    }
    if (self.isRepeat) {
        NSInteger reCount = self.isRepeat ? (count + self.visibleCount - 1) : count;
        if (self.currentIndex < reCount - 1) {
            // 当前数据源还有数据 继续创建cell
            [self createCardViewCellWithIndex:(self.currentIndex + 1) % count];
        } else {
            // 如果是重复的情况下需要加载到最后一张就重载
            [self reloadDataRepeatAnimated:YES];
        }
    }
    else {
        // 当前数据源还有数据 继续创建cell
        if (self.currentIndex < count - 1) {
            [self createCardViewCellWithIndex:(self.currentIndex + 1)];
        }
    }
    // 更新布局
    [self updateLayoutVisibleCellsWithAnimated:YES];
}

- (void)cardViewCellDidMoveFromSuperView:(GXCardViewCell *)cell forMovePoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(cardView:didMoveCell:forMovePoint:direction:)]) {
        // 右滑中
        if (cell.currentPoint.x > cell.maxRemoveDistance) {
            [self.delegate cardView:self didMoveCell:cell forMovePoint:point direction:GXCardCellSwipeDirectionRight];
        }
        // 左滑中
        else if (cell.currentPoint.x < -cell.maxRemoveDistance) {
            [self.delegate cardView:self didMoveCell:cell forMovePoint:point direction:GXCardCellSwipeDirectionLeft];
        }
        // 滑动距离不够
        else {
             [self.delegate cardView:self didMoveCell:cell forMovePoint:point direction:GXCardCellSwipeDirectionNone];
        }
    }
}

@end


