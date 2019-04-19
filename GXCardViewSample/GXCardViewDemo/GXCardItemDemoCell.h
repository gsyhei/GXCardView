//
//  GXCardItemDemoCell.h
//  GXCardViewDemo
//
//  Created by Gin on 2018/8/3.
//  Copyright © 2018年 gin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXCardView.h"

@interface GXCardItemDemoCell : GXCardViewCell

@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@end
