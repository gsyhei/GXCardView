//
//  UIView+Operation.h
//  C2B_Test
//
//  Created by Gin on 15/11/26.
//  Copyright © 2015年 eggame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GXAdd)

/**
 *  frame属性添加
 */
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic, assign) CGPoint origin;

/*!
 *  @brief 自定义底部线条
 */
@property (nonatomic, assign) UIView *lineView;

/**
 *  加载xib view
 *
 *  @param owner 所有者
 *
 *  @return  view
 */
+ (instancetype)sharedView:(id)owner;

/**
 *  加载xib view
 *
 *  @param owner    所有者
 *  @param nibNamed xib名
 *  @param index    xib索引
 *
 *  @return view
 */
+ (instancetype)sharedView:(id)owner loadNibNamed:(NSString*)nibNamed index:(NSInteger)index;

/**
 *  圆形风格view
 */
- (void)styleCircle;

/**
 *  删除所以子view
 */
- (void)removeAllSubviews;

/**
 *  形状裁剪（实际为形状遮罩）
 *
 *  @param image 需要的形状图片
 */
- (void)maskImage:(UIImage *)image;

/**
 *  快照
 *
 *  @param afterUpdates 适合scale
 *
 *  @return 快照图片
 */
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
- (UIImage *)snapshotImage;

/**
 *  @brief 获取当前window
 *
 *  @return 当前可用window
 */
+ (UIWindow*)currentWindow;

/*!
 *  @brief 获得响应控制器
 *
 *  @return vc
 */
- (UIViewController *)viewController;

/*!
 *  @brief 设置矩形某个角的圆角边
 *
 *  @param corners 角度
 *  @param radius  半径
 */
- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;

@end


@interface UITableView (Operation)

/**
 *  下划线左对齐
 */
- (void)setSeparatorLeadingLeft;

/**
 *  设置footerView去掉多余的分割线
 */
- (void)setTableFooterViewZero;

/**
 *  Remove touch delay (since iOS 8)
 */
- (void)cancelDelaysContentTouches NS_AVAILABLE_IOS(8_0);

@end


@interface UITableViewCell (Operation)

/**
 *  下划线左对齐
 */
- (void)setSeparatorLeadingLeft;

/**
 *  获取nib
 *
 *  @return nib
 */
+ (UINib *)nib;

/**
 *  获取cell重用标识
 *
 *  @return cell标识
 */
+ (NSString *)cellReuseIdentifier;

@end

@interface UITableViewHeaderFooterView (Operation)

/**
 *  获取nib
 *
 *  @return nib
 */
+ (UINib *)nib;

/**
 *  获取cell重用标识
 *
 *  @return cell标识
 */
+ (NSString *)cellReuseIdentifier;

@end

@interface UICollectionReusableView (Operation)

/**
 *  获取nib
 *
 *  @return nib
 */
+ (UINib *)nib;

/**
 *  获取cell重用标识
 *
 *  @return cell标识
 */
+ (NSString *)cellReuseIdentifier;


@end


@interface UIViewController (Operation)

/**
 *  加载xib viewController
 *
 *  @return viewController
 */
+ (instancetype)sharedViewController;

/*
 *  添加返回按钮
 */
- (void)addBackBarButtonItem;
- (void)addBackBarButtonItemWithImage:(NSString*)image;

@end

@interface UIScrollView (Operation)

@end
