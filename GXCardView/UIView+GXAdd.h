//
//  UIView+GXAdd.h
//  GXCardViewDemo
//
//  Created by Gin on 2018/8/5.
//  Copyright © 2018年 gin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GXAdd)

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

/**
 *  删除所以子view
 */
- (void)removeAllSubviews;

@end
