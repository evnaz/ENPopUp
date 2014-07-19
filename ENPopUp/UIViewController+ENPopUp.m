//
//  UIViewController+ENPopUp.m
//  ENPopUp
//
//  Created by Evgeny on 28.06.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import "UIViewController+ENPopUp.h"
#import "JWBlurView.h"
#import <objc/runtime.h>

static void * ENPopupViewControllerPropertyKey = &ENPopupViewControllerPropertyKey;

static CGFloat const kAnimationDuration = .4f;
static CGFloat const kRotationAngle = 70.f;

static NSInteger const kENPopUpOverlayViewTag   = 351301;
static NSInteger const kENPopUpViewTag          = 351302;
static NSInteger const kENPopUpBluredViewTag    = 351303;

@implementation UIViewController (ENPopUp)

#pragma mark - Public Methods
- (void)presentPopUpViewController:(UIViewController *)popupViewController
{
    self.en_popupViewController = popupViewController;
    [self presentPopUpView:popupViewController.view];
}

- (void)dismissPopUpViewController
{
    [self dismissingAnimation];
}

#pragma mark - Getters & Setters
- (UIViewController *)en_popupViewController
{
    return objc_getAssociatedObject(self, ENPopupViewControllerPropertyKey);
}

- (void)setEn_popupViewController:(UIViewController *)en_popupViewController
{
    objc_setAssociatedObject(self, ENPopupViewControllerPropertyKey, en_popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


#pragma mark - View Handling
- (void)presentPopUpView:(UIView *)popUpView
{
    UIView *sourceView = [self topView];
    
    // Check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popUpView]) return;
    
    // Add overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.tag = kENPopUpOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    
    // Add Blured View
    JWBlurView *bluredView = [[JWBlurView alloc] initWithFrame:self.view.bounds];
    bluredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bluredView.tag = kENPopUpBluredViewTag;
    [bluredView setBlurAlpha:.0f];
    [bluredView setAlpha:.0f];
    [bluredView setBlurColor:[UIColor clearColor]];
    bluredView.backgroundColor = [UIColor clearColor];
    [overlayView addSubview:bluredView];
    
    // Make the background clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.bounds;
    [overlayView addSubview:dismissButton];
    
    [dismissButton addTarget:self action:@selector(dismissPopUpViewController)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Customize popUpView
    popUpView.layer.cornerRadius = 3.5f;
    popUpView.layer.masksToBounds = YES;
    popUpView.layer.zPosition = 99;
    popUpView.tag = kENPopUpViewTag;
    popUpView.center = overlayView.center;
    [popUpView setNeedsLayout];
    [popUpView setNeedsDisplay];
    
    [overlayView addSubview:popUpView];
    [sourceView addSubview:overlayView];

    [self setAnimationStateFrom:popUpView];
    [self appearingAnimation];
}



#pragma mark - Animation
- (void)setAnimationStateFrom:(UIView *)view
{
    CALayer *layer = view.layer;
    layer.transform = [self transform3d];
}

- (CATransform3D)transform3d
{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, 200.f, 0);
    transform.m34 = 1.0/800.0;
    transform = CATransform3DRotate(transform, kRotationAngle*M_PI/180.f, 1.f, .0f, .0f);
    CATransform3D scale = CATransform3DMakeScale(.7f, .7f, .7f);
    return CATransform3DConcat(transform, scale);
}

- (void)appearingAnimation
{
    
    CATransform3D transform;
    transform = CATransform3DIdentity;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^ {
                         [self.en_popupViewController viewWillAppear:NO];
                         [[self bluredView] setAlpha:1.f];
                         [self popUpView].layer.transform   = transform;
                     }
                     completion:^(BOOL finished) {
                         [self.en_popupViewController viewDidAppear:NO];
                     }];
}


- (void)dismissingAnimation
{
    CATransform3D transform = [self transform3d];
    [UIView animateWithDuration:kAnimationDuration
                     animations:^ {
                         [self.en_popupViewController viewWillDisappear:NO];
                         [[self bluredView] setAlpha:0.f];
                         [self popUpView].layer.transform   = transform;
                     }
                     completion:^(BOOL finished) {
                         [[self popUpView] removeFromSuperview];
                         [[self bluredView]  removeFromSuperview];
                         [[self overlayView]  removeFromSuperview];
                         [self.en_popupViewController viewDidDisappear:NO];
                         self.en_popupViewController = nil;
                     }];
}

#pragma mark - Getters
- (UIView *)popUpView
{
    return [self.view viewWithTag:kENPopUpViewTag];
}

- (UIView *)overlayView
{
    return [self.view viewWithTag:kENPopUpOverlayViewTag];
}

- (JWBlurView *)bluredView
{
    return (JWBlurView *)[self.view viewWithTag:kENPopUpBluredViewTag];
}

- (UIView*)topView {
    UIViewController *recentView = self;
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

@end
