//
//  ACCostonBtn.m
//  PeopleCounter
//
//  Created by Air_chen on 16/8/7.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACCostonBtn.h"

@implementation ACCostonBtn

- (void)awakeFromNib
{
    [self setUP];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUP];
        
    }
    return self;
}

//按钮的初始化
- (void)setUP{
    
    [self.imageView sizeToFit];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat imageW = self.bounds.size.width;
    CGFloat imageH = self.bounds.size.height * 0.8;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    
    CGFloat labelX = imageX;
    CGFloat labelY = imageH + 5;
    CGFloat labelW = imageW;
    CGFloat labelH = self.bounds.size.height - imageH;
    
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
