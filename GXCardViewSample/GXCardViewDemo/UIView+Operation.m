//
//  UIView+Operation.m
//  C2B_Test
//
//  Created by Gin on 15/11/26.
//  Copyright © 2015年 eggame. All rights reserved.
//

#import "UIView+Operation.h"
#import <objc/runtime.h>

@implementation UIView (Operation)

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (void)setRight:(CGFloat)right {
    if(right == self.right){
        return;
    }
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom {
    if(bottom == self.bottom){
        return;
    }
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)right {
    return self.left + self.width;
}

- (CGFloat)bottom {
    return self.top + self.height;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

static const char DSLineViewKey = '\0';
- (void)setLineView:(UIView *)lineView {
    if (lineView != self.lineView) {
        // 删除旧的，添加新的(由于自定义线条还会穿插阴影,所以每次会先移除添加再赋值新的)
        [self.lineView removeFromSuperview];
        [self addSubview:lineView];
        // 存储新的
        [self willChangeValueForKey:@"lineView"]; // KVO
        objc_setAssociatedObject(self, &DSLineViewKey, lineView, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"lineView"];  // KVO
    }
}

- (UIView *)lineView {
    return objc_getAssociatedObject(self, &DSLineViewKey);
}

+ (instancetype)sharedView:(id)owner {
    return [self sharedView:owner loadNibNamed:NSStringFromClass([self class]) index:0];
}

+ (instancetype)sharedView:(id)owner loadNibNamed:(NSString*)nibNamed index:(NSInteger)index{
    UIView *view = [[[NSBundle mainBundle]loadNibNamed:nibNamed owner:owner options:nil] objectAtIndex:index];
    return view;
}

- (void)styleCircle {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius  = self.frame.size.height/2;
}

- (void)maskImage:(UIImage *)image {
    NSParameterAssert(image != nil);
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(self.frame, 0.f, 0.f);
    self.layer.mask = imageViewMask.layer;
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIView*)snapshotView {
    return [self snapshotViewAfterScreenUpdates:YES];
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

+ (UIWindow*)currentWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        return window;
    } else {
        return [UIApplication sharedApplication].delegate.window;
    }
}

- (UIViewController *)viewController {
    id nextResponder = [self nextResponder];
    if ( [nextResponder isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)nextResponder;
    } else {
        return nil;
    }
}

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    CGRect rect = self.bounds;
    
    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
}

@end


@implementation UITableView (Operation)

- (void)setSeparatorLeadingLeft {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setTableFooterViewZero {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:view];
}

- (void)cancelDelaysContentTouches {
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = NO;
    // Remove touch delay (since iOS 8)
    UIView *wrapView = self.subviews.firstObject;
    // UITableViewWrapperView
    if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
        for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
            // UIScrollViewDelayedTouchesBeganGestureRecognizer
            if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                gesture.enabled = NO;
                break;
            }
        }
    }
}

@end


@implementation UITableViewCell (Operation)

- (void)setSeparatorLeadingLeft {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

@end

@implementation UITableViewHeaderFooterView (Operation)

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

@end

@implementation UICollectionReusableView (Operation)

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

@end


@implementation UIViewController (Operation)

+ (instancetype)sharedViewController {
    return [[[self class] alloc] initWithNibName:NSStringFromClass([self class])
                                          bundle:nil];
}

- (UIBarButtonItem *)sharedWithImage:(NSString *)image contentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment target:(id)target action:(SEL)action {
    UIImage *normalImage = [UIImage imageNamed:image];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    btn.contentHorizontalAlignment = contentHorizontalAlignment;
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    } else {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -6)];
    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)addBackBarButtonItem {
    [self addBackBarButtonItemWithImage:@"fanhui"];
}

- (void)addBackBarButtonItemWithImage:(NSString*)image {
    UIImage *normalImage = [UIImage imageNamed:image];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:normalImage style:UIBarButtonItemStylePlain
                                                                         target:self action:@selector(backBarButtonItemTapped:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)backBarButtonItemTapped:(id)sender {
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

@implementation UIScrollView (Operation)


@end
