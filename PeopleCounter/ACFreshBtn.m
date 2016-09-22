//
//  ACFreshBtn.m
//  PeopleCounter
//
//  Created by Air_chen on 16/9/1.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ACFreshBtn.h"

@interface ACFreshBtn()

@property (nonatomic, readwrite, strong) UIView *smallView;
@property (nonatomic, readwrite, strong) CAShapeLayer *shapeLayer;

@end

@implementation ACFreshBtn

- (CAShapeLayer *)shapeLayer
{
    if (_shapeLayer == nil) {
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor orangeColor].CGColor;
        
        _shapeLayer = layer;
        
        [self.superview.layer insertSublayer:layer atIndex:0];
    }
    return _shapeLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpUI];
}

- (void)setUpUI
{
    self.autoresizesSubviews = NO;
    
    self.layer.cornerRadius = self.bounds.size.width / 2.0;
    
    UIView *smallView = [[UIView alloc] initWithFrame:self.frame];
    smallView.backgroundColor = [UIColor orangeColor];
    smallView.layer.cornerRadius = self.bounds.size.width / 2.0;
    self.smallView = smallView;
    [self.superview insertSubview:smallView belowSubview:self];
    
    
}

- (void)moveDistance:(CGFloat)dis inType:(ACMoveType)type
{
    if (type == ACMoveBegin) {
        self.hidden = NO;
        self.smallView.hidden = NO;
        self.center = self.smallView.center;
        [self.superview.layer insertSublayer:self.shapeLayer atIndex:0];
    }
    
    if (dis > 75.0) {
        //animate
        CGPoint pp = self.center;
        self.center = CGPointMake(pp.x, pp.y - dis + 75.0);
        
        CGFloat distance = [self distanceFromView:self.smallView toView:self];
        //取出小圆的半径.
        CGFloat radius = self.bounds.size.width * 0.5;
        radius = radius - distance / 5.0;
        //重新设置小圆的宽高
        self.smallView.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
        self.smallView.layer.cornerRadius = radius;
        
//        //调整大圆半径
        CGFloat radius2 = self.bounds.size.width * 0.5 - distance / 11.0;
        self.bounds = CGRectMake(0, 0, radius2*2, radius2*2);
        self.layer.cornerRadius = radius2;
        
        if (!self.smallView.hidden) {
            UIBezierPath *path = [self drawPathBetreenViews];
            self.shapeLayer.path = path.CGPath;
        }

        
        if (dis > 110.0) {
            
            self.smallView.hidden = YES;
            [self.shapeLayer removeFromSuperlayer];
            
            //播放一个动画
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.bounds];
            
            NSMutableArray *imageArray = [NSMutableArray array];
            
            for (int i = 0; i < 8; i++) {
                NSString *imageName  = [NSString stringWithFormat:@"%d",i+1];
                UIImage *image = [UIImage imageNamed:imageName];
                [imageArray addObject:image];
            }
            
            imageV.animationImages = imageArray;
            [imageV setAnimationDuration:1];
            [imageV startAnimating];
            [self addSubview:imageV];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imageV removeFromSuperview];
                self.hidden = YES;
            });

        }
        
    }else
    {
        if (!self.smallView.hidden) {
            UIBezierPath *path = [self drawPathBetreenViews];
            self.shapeLayer.path = path.CGPath;
        }
        
        self.smallView.center = self.center;
    }
    
    if (type == ACMoveEnd) {
        self.center = self.smallView.center;
    }
}

- (UIBezierPath *)drawPathBetreenViews
{
    CGFloat x1 = self.smallView.center.x;
    CGFloat y1 = self.smallView.center.y;
    CGFloat r1 = self.smallView.bounds.size.width / 2.0;
    CGFloat x2 = self.center.x;
    CGFloat y2 = self.center.y;
    CGFloat r2 = self.bounds.size.width / 2.0;
    CGFloat distance = [self distanceFromView:self.smallView toView:self];
    
    CGFloat cos = (y2 - y1)/distance;
    CGFloat sin = (x2 - x1)/distance;
    
    CGPoint A = CGPointMake(x1 - r1*cos, y1 + r1*sin);
    CGPoint B = CGPointMake(x1 + r1*cos, y1 - r1*sin);
    CGPoint C = CGPointMake(x2 + r2*cos, y2 - r2*sin);
    CGPoint D = CGPointMake(x2 - r2*cos, y2 + r2*sin);
    
    CGPoint O = CGPointMake(A.x + distance/2*sin, A.y + distance/2*cos);
    CGPoint P = CGPointMake(B.x + distance/2*sin, B.y + distance/2*cos);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:A];
    [path addLineToPoint:B];
    [path addQuadCurveToPoint:C controlPoint:P];
    [path addLineToPoint:D];
    [path addQuadCurveToPoint:A controlPoint:O];
    
    return path;
    
}

- (CGFloat)distanceFromView:(UIView *)view toView:(UIView *)otherView
{
    CGFloat offsetX = view.center.x - otherView.center.x;
    CGFloat offsetY = view.center.y - otherView.center.y;
    
    return sqrtf(offsetX * offsetX + offsetY * offsetY);
}


@end
