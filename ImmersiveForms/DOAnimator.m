//
//  DOAnimator.m
//  ImmersiveForms
//
//  Created by David Olesch on 3/25/14.
//  Copyright (c) 2014 David Olesch. All rights reserved.
//

#import "DOAnimator.h"
#import "DOFormViewController.h"
#import "DOViewController.h"

@implementation DOAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        return 0.3f;
    }
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    DOViewController *presentingViewController;
    DOFormViewController *overlayViewController;
    double initialAlpha;
    double finalAlpha;
    
    if (self.presenting) {
        initialAlpha = 0.f;
        finalAlpha = 0.95f;
        presentingViewController  = (DOViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        overlayViewController = (DOFormViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    else {
        initialAlpha = 0.95f;
        finalAlpha = 0.f;
        overlayViewController  = (DOFormViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        presentingViewController = (DOViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
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
