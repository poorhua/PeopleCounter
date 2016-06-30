//
//  InformViewModel.h
//  PeopleCounter
//
//  Created by Air_chen on 16/6/29.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlobalHeader.h"

@interface InformViewModel : NSObject

@property (strong, nonatomic)  UITextView *inputTextField;
@property (strong, nonatomic)  UITextView *transTextField;
@property (strong, nonatomic)  UITextField *nameTextField;
@property (strong, nonatomic)  UIButton *transBtn;
@property (strong, nonatomic)  UIButton *sendBtn;
@property(nonatomic,strong) UIControl *viewControl;
@property(nonatomic,strong) UIStackView *stackView;
@property(nonatomic,strong) NSLayoutConstraint *buttonConstraint;
@property(nonatomic,strong) RACCommand *informCommand;

@end
