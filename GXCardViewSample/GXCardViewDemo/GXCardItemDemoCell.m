//
//  GXCardItemDemoCell.m
//  GXCardViewDemo
//
//  Created by Gin on 2018/8/3.
//  Copyright © 2018年 gin. All rights reserved.
//

#import "GXCardItemDemoCell.h"

@implementation GXCardItemDemoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0;
    //    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    //    self.layer.shadowRadius = 4.0;
    //    self.layer.shadowOpacity = 0.4;
    //    self.layer.shadowColor = [UIColor grayColor].CGColor;
}

@end
