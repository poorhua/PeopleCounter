//
//  ACButtonView.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/6.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACButtonView.h"

@interface ACButtonView()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation ACButtonView

+(instancetype)getButtonView
{
    return [[NSBundle mainBundle] loadNibNamed:@"ACButtonView" owner:nil options:nil][0];
}

-(void)awakeFromNib
{
    self.layer.cornerRadius = 5;
}

-(void)turnSlop
{
    [UIView animateWithDuration:0.3 animations:^{
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, M_PI/4.0);
    } completion:nil];
}

-(void)turnOrign
{
    [UIView animateWithDuration:0.3 animations:^{
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, -M_PI/4.0);
    } completion:nil];
}

@end
