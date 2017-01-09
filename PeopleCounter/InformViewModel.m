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
#import "ACTranslateManager.h"

@interface InformViewModel()<UITextFieldDelegate, UITextViewDelegate>

@end

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
        [self.viewController.view addGestureRecognizer:tap];
        
        //输入框的事件绑定
        if (self.viewController.view.bounds.size.width != 414) {
            self.heightContraint.constant = 360;
        }
        
        self.nameTextField.text = @"";
        self.detailTextView.text = @"";
        
        self.nameTextField.delegate = self;
        self.detailTextView.delegate = self;
        
//        当键盘出现的时候，调整布局，便于输入文字
        __block BOOL isDrop = NO;
        __block CGFloat orgHeight = self.heightContraint.constant;
        __block CGFloat compHeight = 0.0;
        
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] subscribeNext:^(id x) {
            NSNotification *noteCenter = x;
        
            CGRect fra = [noteCenter.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            NSTimeInterval dure = [noteCenter.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
            compHeight = fra.size.height;
            
            if ([self.detailTextView isFirstResponder] && !isDrop) {
                self.heightContraint.constant = orgHeight - compHeight;
                isDrop = YES;
            }
            
            [UIView animateWithDuration:dure animations:^{
                [self.viewController.view layoutIfNeeded];
            }];
        }];
        
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(id x) {
            NSNotification *noteCenter = x;
            NSTimeInterval dure = [noteCenter.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
            
            if ([self.detailTextView isFirstResponder] && isDrop) {
                self.heightContraint.constant = orgHeight;
                isDrop = NO;
            }
            
            [UIView animateWithDuration:dure animations:^{
                [self.viewController.view layoutIfNeeded];
            }];
        }];
        
//        发送
        [[self.sendBtn rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
            
            [self returnKeyboard];
            [self.nameTextField endEditing:YES];
            [self.detailTextView endEditing:YES];
            
            if ([self.nameTextField.text isEqualToString:@""] || [self.detailTextView.text isEqualToString:@""]) {
                [UIAlertController showAlertInViewController:self.viewController withTitle:@"通知" message:@"请将信息补充完整" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
            }else{
                
                if ([[ACTranslateManager shareManager] isChineseInString:self.nameTextField.text] || [[ACTranslateManager shareManager] isChineseInString:self.detailTextView.text]) {
                    
                    [[RACScheduler mainThreadScheduler] afterDelay:1.0 schedule:^{
                         [[ACNetWorkManager shareManager] postMsgStr:[NSString stringWithFormat:@"%@:%@",self.nameTextField.text,self.detailTextView.text] thatResult:^(RACTuple *resData) {
                            RACTupleUnpack(NSHTTPURLResponse *response,NSData *data) = resData;
                            
                            if (response.statusCode == 200) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [UIAlertController showAlertInViewController:self.viewController withTitle:@"通知" message:@"发送成功" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
                                    
                                });
                                
                            }
                        }];
                    }];
                }
            }
        }];
        
            return [RACSignal empty];
        }];
}

- (void)returnKeyboard
{
    [self.nameTextField resignFirstResponder];
    [self.detailTextView resignFirstResponder];
}

#pragma mark - delegateMethod
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *orgStr = textField.text;
    if ([[ACTranslateManager shareManager] isChineseInString:orgStr]) {
        [[ACTranslateManager shareManager] translateWithOrgString:orgStr withResult:^(NSString *resStr) {
            [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
                textField.text = resStr;
            }];
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *orgStr = textView.text;
    if ([[ACTranslateManager shareManager] isChineseInString:orgStr]) {
        [[ACTranslateManager shareManager] translateWithOrgString:orgStr withResult:^(NSString *resStr) {
            [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
                textView.text = resStr;
            }];
        }];
    }
}

@end
