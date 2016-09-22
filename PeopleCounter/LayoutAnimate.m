//
//  LayoutAnimate.m
//  视图控制器转场
//
//  Created by Air_chen on 16/7/23.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "LayoutAnimate.h"

@implementation LayoutAnimate

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    /*
     UIKit might change the view controllers while adapting to a new trait environment or in response to a request from your app.
     */
    
    
    UIView *containerView = [transitionContext containerView];
    
    UIView *fromView = fromVc.view;
    UIView *toView = toVc.view;
    CGFloat duration = [self transitionDuration:transitionContext];
    
    if ([toVc isBeingPresented]) {
        [containerView addSubview:toView];
        CGFloat toViewWidth = containerView.frame.size.width * 2/3;
        CGFloat toViewHeight = containerView.frame.size.height * 1/6;
        
        toView.center = containerView.center;
        toView.bounds = CGRectMake(0, 0, 1, toViewHeight);
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.bounds = CGRectMake(0, 0, toViewWidth, toViewHeight);
        } completion:^(BOOL finished) {
            BOOL isCancel = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!isCancel];
            /*
             Calling the completeTransition: method at the end of your animations is required. UIKit does not end the transition process, and thereby return control to your app, until you call that method.
             */
        }];
        
    }
    
    if ([fromVc isBeingDismissed]) {
        CGFloat fromViewHeight = fromView.frame.size.height;
        
        [UIView animateWithDuration:duration animations:^{
            fromView.bounds = CGRectMake(0, 0, 1, fromViewHeight);
        } completion:^(BOOL finished) {
            BOOL isCancel = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!isCancel];
        }];
    }
}

@end
