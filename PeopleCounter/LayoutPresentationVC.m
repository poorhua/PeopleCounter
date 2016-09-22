//
//  LayoutPresentationVC.m
//  视图控制器转场
//
//  Created by Air_chen on 16/7/23.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "LayoutPresentationVC.h"

@interface LayoutPresentationVC()

@property (nonatomic, readwrite, strong) UIView *dimmingView;

@end

@implementation LayoutPresentationVC

- (void)presentationTransitionWillBegin
{
    CGFloat viewWidth = self.containerView.bounds.size.width *2/3;
    CGFloat viewHeight = self.containerView.bounds.size.height *2/3;
    self.dimmingView = [[UIView alloc] init];
    [self.containerView addSubview:self.dimmingView];
    self.dimmingView.bounds = CGRectMake(0, 0, viewWidth, viewHeight);
    self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.dimmingView.center = self.containerView.center;
    
    UITapGestureRecognizer *geture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.dimmingView addGestureRecognizer:geture];
    
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                self.dimmingView.bounds = self.containerView.bounds;
            } completion:nil];

}

- (void)tapAction
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissalTransitionWillBegin
{
    /*
     The blocks you provide are stored until the transition animations begin, at which point they are executed along with the rest of the transition animations.
     */
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0.0;
    } completion:nil];
}

- (void)containerViewWillLayoutSubviews
{
    self.dimmingView.center = self.containerView.center;
    self.dimmingView.bounds = self.containerView.bounds;
    
    CGFloat viewWidth = self.containerView.bounds.size.width *2/3;
    CGFloat viewHeight = self.containerView.bounds.size.height *2/3;
    self.presentedView.center = self.containerView.center;
    self.presentedView.bounds = CGRectMake(0, 0, viewWidth, viewHeight);
}

@end
