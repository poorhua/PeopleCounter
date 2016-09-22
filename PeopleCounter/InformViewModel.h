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

@property (nonatomic, readwrite, weak) UITextView *inputTextField;
@property (nonatomic, readwrite, weak) UITextView *transTextField;
@property (nonatomic, readwrite, weak) UITextField *nameTextField;
@property (nonatomic, readwrite, weak) UIButton *transBtn;
@property (nonatomic, readwrite, weak) UIButton *sendBtn;
@property (nonatomic, readwrite, weak) UIControl *viewControl;
@property (nonatomic, readwrite, weak) UIStackView *stackView;
@property (nonatomic, readwrite, weak) NSLayoutConstraint *buttonConstraint;
@property (nonatomic, readwrite, strong, nonnull) RACCommand *informCommand;

@end
