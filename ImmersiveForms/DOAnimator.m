//
//  DOAnimator.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/25/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOAnimator.h"

@implementation DOAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *presentingViewController;
    UIViewController *overlayViewController;
    double initialAlpha;
    double finalAlpha;
    
    if (self.presenting) {
        initialAlpha = 0.f;
        finalAlpha = 0.9f;
        presentingViewController  = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        overlayViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    else {
        initialAlpha = 0.9f;
        finalAlpha = 0.f;
        overlayViewController  = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        presentingViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:presentingViewController.view];
    [containerView addSubview:overlayViewController.view];
    
    overlayViewController.view.alpha = initialAlpha;
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:transitionDuration
                     animations:^{
                         overlayViewController.view.alpha = finalAlpha;
                     } completion:^(BOOL finished) {
                         BOOL transitionWasCancelled = [transitionContext transitionWasCancelled];
                         [transitionContext completeTransition:transitionWasCancelled == NO];
                     }];
}


@end
