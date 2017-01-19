//
//  ACMainViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/19.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACMainViewModel.h"
#import "MDTransitionDelegate.h"
#import "PlotViewController.h"
#import "ACButtonView.h"
#import "ACNetWorkManager.h"
#import "ACDevModel.h"
#import "ACMainViewController.h"

@interface ACMainViewModel()

@property (nonatomic, readwrite, strong) MDTransitionDelegate *transitionalDelegate;
@property (nonatomic, readwrite, copy) NSArray *humanArray;
@property (nonatomic, readwrite, copy) NSArray *tempArray;
@property (nonatomic, readwrite, copy) NSArray *airArray;

@property (nonatomic, readwrite, strong) UILabel *label;
@property (nonatomic, readwrite, assign) BOOL isCombo;
@property (nonatomic, readwrite, strong) ACButtonView *btnSubView;

@property (nonatomic, readwrite, assign) BOOL isTap;
@end

@implementation ACMainViewModel

- (MDTransitionDelegate *)transitionalDelegate
{
    if (_transitionalDelegate == nil) {
        _transitionalDelegate = [[MDTransitionDelegate alloc] init];
    }
    return _transitionalDelegate;
}

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
    }
    
    return _label;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self bindEvents];
    }
    return self;
}

- (void)bindEvents
{
    self.acMainCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        self.label.text = acAppName;
        //    自动设置了尺寸
        [self.label sizeToFit];
        self.label.textColor = [UIColor orangeColor];
        self.navigationItem.titleView = self.label;
        
        
        ACButtonView *btnView = [ACButtonView getButtonView];
        btnView.frame = self.btnView.bounds;
        [self.btnView addSubview:btnView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [btnView addGestureRecognizer:gesture];
        self.isCombo = true;
        self.btnSubView = btnView;
        
        UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recoverView)];
        [self.comboView addGestureRecognizer:gesture1];
        
        [self hideBtns];
        
        self.isTap = YES;
        //bindAction
        [self.humanBtn addTarget:self action:@selector(humanAction) forControlEvents:UIControlEventTouchUpInside];
        [self.airBtn addTarget:self action:@selector(airAction) forControlEvents:UIControlEventTouchUpInside];
        [self.tempBtn addTarget:self action:@selector(tempAction) forControlEvents:UIControlEventTouchUpInside];
        
        return [RACSignal empty];
        
    }];
}

- (void)hideBtns
{
    self.humanBtn.transform = CGAffineTransformTranslate(self.humanBtn.transform, 0, 246);
    self.tempBtn.transform = CGAffineTransformTranslate(self.tempBtn.transform, -102, 163);
    self.airBtn.transform = CGAffineTransformTranslate(self.airBtn.transform, 102, 163);
}

- (void)recoverView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.comboView.alpha = 0.0;
        
        [self.label setAlpha:1];
        
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor orangeColor];
        
        [self hideBtns];
    }];
    [self.btnSubView turnOrign];
    self.isCombo = YES;
}

- (void)tapAction
{
    if (self.isCombo) {
        
        //加载数据
        [self loadDatas];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.comboView.alpha = 0.9;
            
            [self.label setAlpha:0];
            
            self.humanBtn.transform = CGAffineTransformIdentity;
            self.tempBtn.transform = CGAffineTransformIdentity;
            self.airBtn.transform = CGAffineTransformIdentity;
            
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithWhite:1 alpha:0];
        }];
        
        [self.btnSubView turnSlop];
        self.isCombo = NO;
    }else
    {
        [self recoverView];
    }
}

//按键点击事件
- (void)humanAction
{
    if (self.isTap) {
        PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
        plotVc.modalPresentationStyle = UIModalPresentationCustom;
        plotVc.transitioningDelegate = self.transitionalDelegate;
        
        [plotVc setDataArray:self.humanArray inStyle:SeekHuman];
        
        [self.navigationController presentViewController:plotVc animated:YES completion:nil];
    }
}

- (void)airAction
{
    if (self.isTap) {
        PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
        plotVc.modalPresentationStyle = UIModalPresentationCustom;
        plotVc.transitioningDelegate = self.transitionalDelegate;
        
        [plotVc setDataArray:self.airArray inStyle:SeekAir];
        
        [self.navigationController presentViewController:plotVc animated:YES completion:nil];
    }
}

- (void)tempAction
{
    if (self.isTap) {
        PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
        plotVc.modalPresentationStyle = UIModalPresentationCustom;
        plotVc.transitioningDelegate = self.transitionalDelegate;
        
        [plotVc setDataArray:self.tempArray inStyle:SeekTemp];
        
        [self.navigationController presentViewController:plotVc animated:YES completion:nil];
    }
}

//点击一下案件下载一次数据
- (void)loadDatas
{
    [[ACNetWorkManager shareManager] getWithUrlStr:enviromentUrl thatResult:^(RACTuple *resData) {
        RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
        
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //                        状态码
        NSLog(@"%ld",(long)response.statusCode);
        
        NSLog(@"%@",content);
        
        NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        ACDevModel *devModel = [ACDevModel setUpDevModelFromDic:initDic];
        
        if (devModel.data.count == 0) {
            [UIAlertController showAlertInViewController:self.controller withTitle:@"提示" message:@"没有传感器数据" cancelButtonTitle:@"确定" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            }];
            self.isTap = NO;
            self.tempArray = [NSArray array];
            self.humanArray = [NSArray array];
            self.airArray = [NSArray array];
        }else{
            self.isTap = YES;
            self.tempArray = devModel.data.datastreams[0].datapoints;
            self.humanArray = devModel.data.datastreams[1].datapoints;
            self.airArray = devModel.data.datastreams[2].datapoints;
        }

    }];
}

@end
