//
//  ACNetWork.m
//  PeopleCounter
//
//  Created by Air_chen on 2016/12/28.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACNetWorkManager.h"

@implementation ACNetWorkManager
static ACNetWorkManager *instance = nil;

+ (instancetype)shareManager
{
    if (instance == nil) {
        instance = [[ACNetWorkManager alloc] init];
    }
    return instance;
}

- (void)postMsgStr:(NSString *)msgStr thatResult:(resultBlock)resData
{
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/devices/3124697/datapoints"];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    [request setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:now];
    NSDictionary *reqDic = @{
                             @"datastreams":@[
                                     @{
                                         @"id":@"001",
                                         @"datapoints":@[
                                                 @{
                                                     @"at":strDate,
                                                     @"value":msgStr
                                                     }
                                                 ]
                                         }
                                     ]
                             };
    NSData *reqData = [NSJSONSerialization dataWithJSONObject:reqDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *content = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",content);
    
    [request setHTTPBody:reqData];
    
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        resData(x);
    }];
}

- (void)getPicUuidStr:(NSString *)uuidStr thatResult:(resultBlock)resData
{
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/bindata/%@",uuidStr];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    [request setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        resData(x);
    }];
}

- (void)getUrlStr:(NSString *)urlStr thatResult:(resultBlock)resData
{
#ifdef TRUEDATE
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    //    加上100，然后转化为字符串，取后两位，可以保证以0x的形式出现
    NSRange range;
    range.location = 1;
    range.length = 2;
    
    NSInteger year = [dateComponent year];
    NSString *month = [[NSString stringWithFormat:@"%ld",(long)([dateComponent month]+100)] substringWithRange:range];
    NSString *day = [[NSString stringWithFormat:@"%ld",(long)([dateComponent day]+100)]substringWithRange:range];
    NSString *hour1 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour]+100)] substringWithRange:range];
    NSString *hour2 = [[NSString stringWithFormat:@"%ld",(long)([dateComponent hour] - 1+100)] substringWithRange:range];
    NSString *minute = [[NSString stringWithFormat:@"%ld",(long)([dateComponent minute] - 1+100)] substringWithRange:range];
    NSString *second = [[NSString stringWithFormat:@"%ld",(long)([dateComponent second]+100)] substringWithRange:range];
    
    NSString *endData = [NSString stringWithFormat:@"%ld-%@-%@T%@:%@:%@",(long)year,month,day,hour1,minute,second];
    NSString *startData = [NSString stringWithFormat:@"%ld-%@-%@T%@:%@:%@",(long)year,month,day,hour2,minute,second];
#else
    NSString *endData = nil;
    NSString *startData = nil;
    
    if ([urlStr isEqualToString:uuidUrl]) {
        endData = [NSString stringWithFormat:@"2016-06-23T11:45:00"];
        startData = [NSString stringWithFormat:@"2016-06-23T11:00:00"];
    }else{
        endData = [NSString stringWithFormat:@"2016-08-07T14:20:00"];
        startData = [NSString stringWithFormat:@"2016-08-07T13:20:00"];
    }
    
#endif
    
    NSString *str = [NSString stringWithFormat:@"%@? datastream_id=001 2&start=%@&end=%@",urlStr,startData,endData];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        resData(x);
    }];
}

- (void)youdaoTranslaterStr:(NSString *)contentStr thatResult:(resultBlock)resData
{
    NSString *str = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=RaspiTranslater&key=31594945&type=data&doctype=json&version=1.1&q=%@",contentStr];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
        resData(x);
    }];
}

@end
