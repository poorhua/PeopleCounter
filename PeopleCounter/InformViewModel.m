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
        
        
        
        [[self.transBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
            
            [self.inputTextField resignFirstResponder];
           
            NSLog(@"123");
        }];
        
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
        
        RAC(self.sendBtn,enabled) = [RACSignal combineLatest:@[self.transTextField.rac_textSignal,self.nameTextField.rac_textSignal] reduce:^id(NSString *str1,NSString *str2){
            
            return @(str1.length != 0 && str2.length != 0);
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
        
        
            return [RACSignal empty];
        }];
}

-(void)returnKeyboard
{
    [self.inputTextField resignFirstResponder];
    [self.transTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
}

@end
