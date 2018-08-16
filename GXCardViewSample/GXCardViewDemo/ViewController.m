//
//  ViewController.m
//  GXCardViewDemo
//
//  Created by Gin on 2018/7/31.
//  Copyright © 2018年 gin. All rights reserved.
//

#import "ViewController.h"
#import "GXCardView.h"
#import "GXCardItemDemoCell.h"

@interface ViewController ()<GXCardViewDataSource, GXCardViewDelegate, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet GXCardView *cardView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    
    self.cardView.dataSource = self;
    self.cardView.delegate = self;
    self.cardView.visibleCount = 5;
    self.cardView.lineSpacing = 15.0;
    self.cardView.interitemSpacing = 10.0;
    self.cardView.maxAngle = 15.0;
    self.cardView.maxRemoveDistance = 100.0;
    [self.cardView registerNib:[UINib nibWithNibName:NSStringFromClass([GXCardItemDemoCell class]) bundle:nil] forCellReuseIdentifier:@"GXCardViewCell"];
    [self.cardView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GXCardViewDataSource

- (GXCardViewCell *)cardView:(GXCardView *)cardView cellForRowAtIndex:(NSInteger)index {
    GXCardItemDemoCell *cell = [cardView dequeueReusableCellWithIdentifier:@"GXCardViewCell"];
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)index];
    cell.layer.cornerRadius = 12.0;
    
    return cell;
}

- (NSInteger)numberOfCountInCardView:(UITableView *)cardView {
    return 10;
}

#pragma mark - GXCardViewDelegate

- (void)cardView:(GXCardView *)cardView didRemoveLastCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    [cardView reloadDataAnimated:YES];
}

- (void)cardView:(GXCardView *)cardView didRemoveCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    NSLog(@"didRemoveCell forRowAtIndex = %ld", index);
}

- (void)cardView:(GXCardView *)cardView didDisplayCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    NSLog(@"didDisplayCell forRowAtIndex = %ld", index);
}

- (void)cardView:(GXCardView *)cardView didMoveCell:(GXCardViewCell *)cell forMovePoint:(CGPoint)point {
    //    NSLog(@"move point = %@", NSStringFromCGPoint(point));
}

#pragma mark -

- (IBAction)leftButtonClick:(id)sender {
    [self.cardView removeTopCardViewFromSwipe:GXCardCellSwipeDirectionLeft];
}

- (IBAction)rightButtonClick:(id)sender {
    [self.cardView removeTopCardViewFromSwipe:GXCardCellSwipeDirectionRight];
}

@end
