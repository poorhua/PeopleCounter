//
//  PlotViewController.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/7.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "PlotViewController.h"
#import "GlobalHeader.h"
#import "PlotViewModel.h"
#import "PlotDatas.h"
#import "ACDevModel.h"

@interface PlotViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widConstraints;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *dataLab;
@property (nonatomic, readwrite, strong) PlotViewModel *plotVM;
@property (nonatomic, readwrite, strong) NSMutableArray<PlotDatas *> *datasArray;
@property (nonatomic, readwrite, assign) ACSeekType style;
@end

@implementation PlotViewController

- (PlotViewModel *)plotVM
{
    if (_plotVM == nil) {
        _plotVM = [[PlotViewModel alloc] init];
    }
    return _plotVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleLab.alpha = 0;
    self.dataLab.alpha = 0;
    self.graphView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.graphView.hostedGraph = [self.plotVM createGraphWith:self.datasArray inStyle:self.style];
    
    switch (self.style) {
        case SeekTemp:
            self.titleLab.text = @"当前温度";
            break;
        case SeekAir:
            self.titleLab.text = @"当前空气质量";
            break;
        case SeekHuman:
            self.titleLab.text = @"当前湿度";
            break;
    }
    [self.titleLab sizeToFit];
    
    NSString *labStr = self.datasArray.lastObject.nums;
    NSLog(@"%@",labStr);
    NSString *showStr;
    switch (self.style) {
        case SeekAir:
            if ([labStr isEqualToString:@"1"]) {
                showStr = @"AAAA";
            }
            if ([labStr isEqualToString:@"2"]) {
                showStr = @"AAA";
            }
            if ([labStr isEqualToString:@"3"]) {
                showStr = @"AA";
            }
            if ([labStr isEqualToString:@"4"]) {
                showStr = @"A";
            }
            break;
        case SeekHuman:
            showStr = [NSString stringWithFormat:@"％%@",labStr];
            break;
        case SeekTemp:
            showStr = [NSString stringWithFormat:@"%@℃",labStr];
            break;
    }
    self.dataLab.text = showStr;
    
    CGFloat wid = self.view.bounds.size.width;
    self.widConstraints.constant = wid;
    [UIView animateWithDuration:0.25 animations:^{
        [self.graphView layoutIfNeeded];
        self.graphView.alpha = 0.8;
        self.titleLab.alpha = 1;
        self.dataLab.alpha = 1;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.titleLab.alpha = 0;
    self.dataLab.alpha = 0;
    self.graphView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.widConstraints.constant = 0;
        
        [self.graphView layoutIfNeeded];
        
    }];
}

- (void)setDataArray:(NSArray *)array inStyle:(ACSeekType)style
{
    self.style = style;
    
    NSInteger count = [array count];
    
    NSMutableArray<PlotDatas *>* datasArray = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; i++) {
            ACDevPointModel *point = array[i];
            PlotDatas *plotData = [[PlotDatas alloc] init];
            [plotData setNums:point.value];
            [plotData setDateTimeStr:point.at];
            [datasArray addObject:plotData];
        }
    self.datasArray = datasArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
