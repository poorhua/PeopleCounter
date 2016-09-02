//
//  ACFreshBtn.h
//  PeopleCounter
//
//  Created by Air_chen on 16/9/1.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ACMoveType) {
    ACMoveMoving,
    ACMoveBegin,
    ACMoveEnd
};


@interface ACFreshBtn : UIButton

-(void)moveDistance:(CGFloat)dis inType:(ACMoveType) type;

@end
