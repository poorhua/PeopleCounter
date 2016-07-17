//
//  InformViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/29.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "InformViewModel.h"

@implementation InformViewModel

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
    _informCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //释放键盘
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnKeyboard)];
        self.stackView.userInteractionEnabled = YES;
        [self.stackView addGestureRecognizer:tap];
        [self.viewControl addTarget:self action:@selector(returnKeyboard) forControlEvents:UIControlEventTouchDown];
        
        //输入框的事件绑定
        self.inputTextField.text = @"";
        self.transTextField.text = @"";
        RAC(self.transBtn,enabled) = [self.inputTextField.rac_textSignal map:^id(NSString* value) {
            
            return @(value.length != 0);
        }];
        
        RAC(self.sendBtn,enabled) = [RACSignal combineLatest:@[RACObserve(self.transTextField, text),self.nameTextField.rac_textSignal,self.transTextField.rac_textSignal] reduce:^id(NSString *str1,NSString *str2,NSString *str3){
  
            return @((str1.length != 0 || str3.length != 0) && str2.length != 0);
        }];
        
//        当键盘出现的时候，调整布局，便于输入文字
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] subscribeNext:^(id x) {
            NSNotification *noteCenter = x;
        
            CGRect fra = [noteCenter.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            NSTimeInterval dure = [noteCenter.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
            
            self.buttonConstraint.constant = fra.size.height;
            
            [UIView animateWithDuration:dure animations:^{
                [self.viewControl layoutIfNeeded];
            }];
        }];
        
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(id x) {
            NSNotification *noteCenter = x;
            
            NSTimeInterval dure = [noteCenter.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
            
            self.buttonConstraint.constant = 0;
            
            [UIView animateWithDuration:dure animations:^{
                [self.viewControl layoutIfNeeded];
            }];
        }];
        
//        http请求
//        翻译
        [[self.transBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
            NSMutableURLRequest *request = [self makeUPURLConnection];
            [[[NSURLConnection rac_sendAsynchronousRequest:request] map:^id(RACTuple *value) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = value;
                
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //                        状态码
                NSLog(@"%ld",(long)response.statusCode);
                
                NSLog(@"%@",content);
                
                NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSString *transStr = initDic[@"translation"][0];
                NSLog(@"%@",transStr);
                
                return transStr;
            }] subscribeNext:^(NSString* x) {
                
                [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
                    [self.transTextField setText:x];
                }];
            }];
        }];
        
//        发送
        [[self.sendBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
           
            NSMutableURLRequest *request = [self makeUPURLConnection:[NSString stringWithFormat:@"%@:%@",self.nameTextField.text,self.transTextField.text]];
            
            [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTuple* x) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = x;
                
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //                        状态码
                NSLog(@"%ld",(long)response.statusCode);
                
                NSLog(@"%@",content);
            }];
        }];
        
            return [RACSignal empty];
        }];
}

-(void)returnKeyboard
{
    [self.inputTextField resignFirstResponder];
    [self.transTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
}

-(NSMutableURLRequest *)makeUPURLConnection
{
    NSString *str = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=RaspiTranslater&key=31594945&type=data&doctype=json&version=1.1&q=%@",self.inputTextField.text];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"GET"];
    return request;
}

-(NSMutableURLRequest *)makeUPURLConnection:(NSString *) msg
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSString *strDate = [formatter stringFromDate:now];
    
    NSString *str = [NSString stringWithFormat:@"http://api.heclouds.com/devices/3124697/datapoints"];
    NSLog(@"%@",str);
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:APIKEY forHTTPHeaderField:@"api-key"];
    
    NSDictionary *reqDic = @{
                             @"datastreams":@[
                                     @{
                                         @"id":@"001",
                                         @"datapoints":@[
                                                 @{
                                                     @"at":strDate,
                                                     @"value":msg
                                                     }
                                                 ]
                                         }
                                     ]
                             };
    NSData *reqData = [NSJSONSerialization dataWithJSONObject:reqDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *content = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",content);
    
    [request setHTTPBody:reqData];
    return request;
}


@end
