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

@interface ACMainViewModel()

@property (nonatomic, readwrite, strong) MDTransitionDelegate *transitionalDelegate;
@property (nonatomic, readwrite, copy) NSArray *humanArray;
@property (nonatomic, readwrite, copy) NSArray *tempArray;
@property (nonatomic, readwrite, copy) NSArray *airArray;

@property (nonatomic, readwrite, strong) UILabel *label;
@property (nonatomic, readwrite, assign) BOOL isCombo;
@property (nonatomic, readwrite, strong) ACButtonView *btnSubView;

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
    PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
    plotVc.modalPresentationStyle = UIModalPresentationCustom;
    plotVc.transitioningDelegate = self.transitionalDelegate;
    
    [plotVc setDataArray:self.humanArray inStyle:SeekHuman];
    
    [self.navigationController presentViewController:plotVc animated:YES completion:nil];
}

- (void)airAction
{
    PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
    plotVc.modalPresentationStyle = UIModalPresentationCustom;
    plotVc.transitioningDelegate = self.transitionalDelegate;
    
    [plotVc setDataArray:self.airArray inStyle:SeekAir];
    
    [self.navigationController presentViewController:plotVc animated:YES completion:nil];
}

- (void)tempAction
{
    PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
    plotVc.modalPresentationStyle = UIModalPresentationCustom;
    plotVc.transitioningDelegate = self.transitionalDelegate;
    
    [plotVc setDataArray:self.tempArray inStyle:SeekTemp];
    
    [self.navigationController presentViewController:plotVc animated:YES completion:nil];
}

//点击一下案件下载一次数据
- (void)loadDatas
{
    NSMutableURLRequest *request = [self makeUPURLConnection];
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        
        RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = x;
        
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //                        状态码
        NSLog(@"%ld",(long)response.statusCode);
        
        NSLog(@"%@",content);
        
        NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *initArray = initDic[@"data"][@"datastreams"];
        //
        self.tempArray = initArray[0][@"datapoints"];
        self.humanArray = initArray[1][@"datapoints"];
        self.airArray = initArray[2][@"datapoints"];
    }];
}

- (NSMutableURLRequest *)makeUPURLConnection
{
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSInteger year = [dateComponent year];
    //    加上100，然后转化为字符串，取后两位，可以保证以0x的形式出现
    NSRange range;
    range.location = 1;
    range.length = 2;
    
    
#ifdef TRUEDATE
    NSString *month = [[NSString stringWithFormat:@"%ld",(long)([dateComponent month]+100)] substringWithRange:range];
    NSString *day = [[NSString stringWithFormat:@"%ld",(long)([dateComponent day]+100)]substringWithRange:range];
    NSString *hour1 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour]+100)] substringWithRange:range];
    NSString *hour2 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour] - 1+100)] substringWithRange:range];
    NSString *minute = [[NSString stringWithFormat:@"%ld",(long)([dateComponent minute] - 1+100)] substringWithRange:range];
    NSString *second = [[NSString stringWithFormat:@"%ld",(long)([dateComponent second]+100)] substringWithRange:range];
    
    NSString *endData = [NSString stringWithFormat:@"%ld-%@-%@T%@:%@:%@",(long)year,month,day,hour1,minute,second];
    NSString *startData = [NSString stringWithFormat:@"%ld-%@-%@T%@:%@:%@",(long)year,month,day,hour2,minute,second];
#else
    NSString *endData = [NSString stringWithFormat:@"%ld-08-07T14:20:00",(long)year];
    NSString *startData = [NSString stringWithFormat:@"%ld-08-07T13:20:00",(long)year];
#endif
    
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/devices/3124912/datapoints? datastream_id=001 2&start=%@&end=%@",startData,endData];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    return request;
}

@end
