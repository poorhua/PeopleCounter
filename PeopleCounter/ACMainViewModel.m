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

@property(nonatomic,strong) MDTransitionDelegate *transitionalDelegate;
@property(nonatomic,strong) NSArray *humanArray;
@property(nonatomic,strong) NSArray *tempArray;
@property(nonatomic,strong) NSArray *airArray;

@property(nonatomic,strong) UILabel *label;
@property(nonatomic,assign) BOOL isCombo;
@property(nonatomic,strong) ACButtonView *btnSubView;

@end

@implementation ACMainViewModel

-(MDTransitionDelegate *)transitionalDelegate
{
    if (_transitionalDelegate == nil) {
        _transitionalDelegate = [[MDTransitionDelegate alloc] init];
    }
    return _transitionalDelegate;
}

-(UILabel *)label
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

-(void)bindEvents
{
    _acMainCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        self.label.text = @"远程监测客户端";
        //    自动设置了尺寸
        [self.label sizeToFit];
        self.label.textColor = [UIColor orangeColor];
        self.navigationItem.titleView = self.label;
        
        
        ACButtonView *btnView = [ACButtonView getButtonView];
        btnView.frame = _btnView.bounds;
        [_btnView addSubview:btnView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [btnView addGestureRecognizer:gesture];
        _isCombo = true;
        _btnSubView = btnView;
        
        [self hideBtns];
        
        //bindAction
        [_humanBtn addTarget:self action:@selector(humanAction) forControlEvents:UIControlEventTouchUpInside];
        [_airBtn addTarget:self action:@selector(airAction) forControlEvents:UIControlEventTouchUpInside];
        [_tempBtn addTarget:self action:@selector(tempAction) forControlEvents:UIControlEventTouchUpInside];
        
        return [RACSignal empty];
        
    }];
}

-(void)hideBtns
{
    _humanBtn.transform = CGAffineTransformTranslate(_humanBtn.transform, 0, 246);
    _tempBtn.transform = CGAffineTransformTranslate(_tempBtn.transform, -102, 163);
    _airBtn.transform = CGAffineTransformTranslate(_airBtn.transform, 102, 163);
}

-(void)recoverView
{
    [UIView animateWithDuration:0.2 animations:^{
        _comboView.alpha = 0.0;
        
        [_label setAlpha:1];
        
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor orangeColor];
        
        [self hideBtns];
    }];
    [_btnSubView turnOrign];
    _isCombo = YES;
}

-(void)tapAction
{
    if (_isCombo) {
        
        //加载数据
        [self loadDatas];
        
        [UIView animateWithDuration:0.2 animations:^{
            _comboView.alpha = 0.9;
            
            [_label setAlpha:0];
            
            _humanBtn.transform = CGAffineTransformIdentity;
            _tempBtn.transform = CGAffineTransformIdentity;
            _airBtn.transform = CGAffineTransformIdentity;
            
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithWhite:1 alpha:0];
        }];
        
        [_btnSubView turnSlop];
        _isCombo = NO;
    }else
    {
        [self recoverView];
    }
}

//按键点击事件
-(void)humanAction
{
    PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
    plotVc.modalPresentationStyle = UIModalPresentationCustom;
    plotVc.transitioningDelegate = self.transitionalDelegate;
    
    [plotVc setDataArray:_humanArray inStyle:SeekHuman];
    
    [self.navigationController presentViewController:plotVc animated:YES completion:nil];
}

-(void)airAction
{
    PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
    plotVc.modalPresentationStyle = UIModalPresentationCustom;
    plotVc.transitioningDelegate = self.transitionalDelegate;
    
    [plotVc setDataArray:_airArray inStyle:SeekAir];
    
    [self.navigationController presentViewController:plotVc animated:YES completion:nil];
}

-(void)tempAction
{
    PlotViewController *plotVc = [[PlotViewController alloc] initWithNibName:@"PlotViewController" bundle:nil];
    plotVc.modalPresentationStyle = UIModalPresentationCustom;
    plotVc.transitioningDelegate = self.transitionalDelegate;
    
    [plotVc setDataArray:_tempArray inStyle:SeekTemp];
    
    [self.navigationController presentViewController:plotVc animated:YES completion:nil];
}

//点击一下案件下载一次数据
-(void)loadDatas
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
        _tempArray = initArray[0][@"datapoints"];
        _humanArray = initArray[1][@"datapoints"];
        _airArray = initArray[2][@"datapoints"];
    }];
}

-(NSMutableURLRequest *)makeUPURLConnection
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
    NSString *month = [[NSString stringWithFormat:@"%ld",(long)([dateComponent month]+100)] substringWithRange:range];
    NSString *day = [[NSString stringWithFormat:@"%ld",(long)([dateComponent day]+100)]substringWithRange:range];
    NSString *hour1 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour]+100)] substringWithRange:range];
    NSString *hour2 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour] - 1+100)] substringWithRange:range];
    NSString *minute = [[NSString stringWithFormat:@"%ld",(long)([dateComponent minute] - 1+100)] substringWithRange:range];
    NSString *second = [[NSString stringWithFormat:@"%ld",(long)([dateComponent second]+100)] substringWithRange:range];
    
#ifdef TRUEDATE
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
    [request setValue:APIKEY forHTTPHeaderField:@"api-key"];
    
    return request;
}

@end
