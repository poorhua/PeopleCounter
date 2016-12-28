//
//  InformViewModel.m
//  PeopleCounter
//
//  Created by Air_chen on 16/6/29.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "InformViewModel.h"
#import "ACNetWorkManager.h"
#import "UIAlertController+Blocks.h"

@implementation InformViewModel

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
    self.informCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //释放键盘
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnKeyboard)];
        self.stackView.userInteractionEnabled = YES;
        [self.stackView addGestureRecognizer:tap];
        [self.viewControl addTarget:self action:@selector(returnKeyboard) forControlEvents:UIControlEventTouchDown];
        
        //输入框的事件绑定
        self.inputTextField.text = @"";
        self.transTextField.text = @"";
        
        [self.transBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateDisabled];
        
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
            
            NSInteger part = 0;
            NSInteger fraHei = fra.size.height;
            //根据不同的输入栏调整不同的高度
            if ([self.inputTextField isFirstResponder]) {
                part = fraHei / 2.0;
            }else if ([self.transTextField isFirstResponder])
                part = fraHei / 3.0;
            else
                part = 0;
            
            self.buttonConstraint.constant = fra.size.height + 20 - part;
            
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
            
            [[ACNetWorkManager shareManager] youdaoTranslaterStr:self.inputTextField.text thatResult:^(RACTuple *resData) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
                
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //                        状态码
                NSLog(@"%ld",(long)response.statusCode);
                
                NSLog(@"%@",content);
                
                NSDictionary *initDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSString *transStr = initDic[@"translation"][0];
                
                [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
                    [self.transTextField setText:transStr];
                }];
            }];
        }];
        
//        发送
        [[self.sendBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
            [self returnKeyboard];
            
            [[ACNetWorkManager shareManager] postMsgStr:[NSString stringWithFormat:@"%@:%@",self.nameTextField.text,self.transTextField.text] thatResult:^(RACTuple *resData) {
                RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
                
                if (response.statusCode == 200) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UIAlertController showAlertInViewController:self.viewController withTitle:@"通知" message:@"发送成功" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
                        
                    });
                    
                }
            }];
        }];
        
            return [RACSignal empty];
        }];
}

- (void)returnKeyboard
{
    [self.inputTextField resignFirstResponder];
    [self.transTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
}

@end
