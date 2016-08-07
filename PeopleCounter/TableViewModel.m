//
//  TableViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/20.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "TableViewModel.h"
#import "CellDatas.h"
#import "DateCell.h"

@interface TableViewModel()

@property(nonatomic,strong) NSMutableArray<CellDatas *>* dataArray;

@end

@implementation TableViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        [self bindEvents];
        
    }
    
    return self;
}

-(void)bindEvents
{
    _httpCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSMutableURLRequest *request = [self makeUPURLConnection];
            [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
                
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = x;
                
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                //                        状态码
                NSLog(@"%ld",(long)response.statusCode);
                
                NSLog(@"%@",content);
                
                NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *initArray = initDic[@"data"][@"datastreams"];
                NSInteger count = [initDic[@"data"][@"count"] integerValue] / 3;
                
                NSArray *firstArray = initArray[0][@"datapoints"];
                NSArray *secArray = initArray[1][@"datapoints"];
                //    NSArray *thrArray = initArray[2][@"datapoints"];//图片
                //    2.加载到数组里面
                //    2.1初始化CellDatas
                NSMutableArray<CellDatas *>* datasArray = [NSMutableArray arrayWithCapacity:count];
                for (int i = 0; i < count; i++) {
                    CellDatas *cellData = [[CellDatas alloc] init];
                    [cellData setDateTimeStr:firstArray[i][@"at"]];
                    [cellData setImgUuid:firstArray[i][@"value"]];
                    [cellData setRecogNumsStr:secArray[i][@"value"]];
                    [datasArray addObject:cellData];
                }
                _dataArray = datasArray;
                
                [subscriber sendNext:datasArray];
                [subscriber sendCompleted];
                
            }];
            
            return nil;
        }];
        return requestSig;
    }];
    
    [[_httpCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            NSLog(@"httping!");
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
        {
            NSLog(@"done!");
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
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
    NSString *endData = [NSString stringWithFormat:@"%ld-06-23T11:45:00",(long)year];
    NSString *startData = [NSString stringWithFormat:@"%ld-06-23T11:00:00",(long)year];
#endif
    
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/devices/1100353/datapoints? datastream_id=001 2&start=%@&end=%@",startData,endData];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    /*
     // Returns a character set containing the characters allowed in an URL's user subcomponent.
     + (NSCharacterSet *)URLUserAllowedCharacterSet NS_AVAILABLE(10_9, 7_0);
     
     // Returns a character set containing the characters allowed in an URL's password subcomponent.
     + (NSCharacterSet *)URLPasswordAllowedCharacterSet NS_AVAILABLE(10_9, 7_0);
     
     // Returns a character set containing the characters allowed in an URL's host subcomponent.
     + (NSCharacterSet *)URLHostAllowedCharacterSet NS_AVAILABLE(10_9, 7_0);
     
     // Returns a character set containing the characters allowed in an URL's path component. ';' is a legal path character, but it is recommended that it be percent-encoded for best compatibility with NSURL (-stringByAddingPercentEncodingWithAllowedCharacters: will percent-encode any ';' characters if you pass the URLPathAllowedCharacterSet).
     + (NSCharacterSet *)URLPathAllowedCharacterSet NS_AVAILABLE(10_9, 7_0);
     
     // Returns a character set containing the characters allowed in an URL's query component.
     + (NSCharacterSet *)URLQueryAllowedCharacterSet NS_AVAILABLE(10_9, 7_0);
     
     // Returns a character set containing the characters allowed in an URL's fragment component.
     + (NSCharacterSet *)URLFragmentAllowedCharacterSet NS_AVAILABLE(10_9, 7_0);
     */
    
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:APIKEY forHTTPHeaderField:@"api-key"];
    
    return request;
}

@end
